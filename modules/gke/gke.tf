#----gke pre-reqs----
resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa-id"
  display_name = "Service Account for GKE"
}
resource "google_kms_crypto_key_iam_binding" "gke_kms_binding" {
  crypto_key_id = var.gke_crypto_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.gke_sa.email}",
    "serviceAccount:${var.compute_sa_email}"
  ]
}
resource "google_kms_crypto_key_iam_binding" "sops_kms_binding" {
  crypto_key_id = var.sops_crypto_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.gke_sa.email}",
    "serviceAccount:${var.compute_sa_email}",
    "serviceAccount:${var.bastion_sa_email}"
  ]
}

data "google_compute_zones" "available_zones" {
  region = var.region
}
#----GKE Cluster----
resource "google_container_cluster" "gke_cluster" {
  name           = "gke-cluster-${var.environment}"
  location       = var.region
  node_locations = slice(data.google_compute_zones.available_zones.names, 0, 1)
  # logging_service          = "none"
  # monitoring_service       = "none"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.gke_subnet_name

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.gke_subnet_ip # GKE subnet CIDR
      display_name = "GKE Subnet"
    }
    cidr_blocks {
      cidr_block   = var.public_subnet_ip # Bastion subnet CIDR
      display_name = "Bastion Subnet"
    }
    cidr_blocks {
      cidr_block   = var.local_ip # Local IP CIDR
      display_name = "Developer IP"
    }
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_ranges
    services_secondary_range_name = var.service_ranges
  }
  # required to enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  #binary auth
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
  deletion_protection = false
  min_master_version  = var.kubernetes_version

}
#----GKE Node Pool----
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name           = "node-pool-${var.environment}"
  location       = var.region #Regional
  node_locations = slice(data.google_compute_zones.available_zones.names, 0, 3)
  #multizone (first two available zones list)
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 1 #nodes per zone
  version    = var.node_version

  node_config {
    preemptible       = true
    machine_type      = var.machine_type #Defaults to e2-medium
    image_type        = "COS_CONTAINERD"
    disk_size_gb      = 50 #Defaults to 100
    disk_type         = var.disk_type
    service_account   = google_service_account.gke_sa.email
    boot_disk_kms_key = var.gke_crypto_key_id

    # required to enable workload identity on node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

#----Google Service Account----
resource "google_service_account" "workload_identity_gsa" {
  account_id   = "api-server-gsa"
  display_name = "GSA for API Server Workload Identity"
}
resource "google_service_account" "db_operator_gsa" {
  account_id   = "db-operator-gsa"
  display_name = "GSA for DB Operator Workload Identity"
}

#----Grant IAM Role to GSA----
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.workload_identity_gsa.email}"
}

resource "google_project_iam_member" "storage_access" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_gsa.email}"
}
resource "google_project_iam_member" "storage_access_db_operator" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.db_operator_gsa.email}"
}

#----Bind KSA to GSA----
resource "google_service_account_iam_binding" "api_server_workload_identity_binding" {
  service_account_id = google_service_account.workload_identity_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.api_server_namespace}/${var.api_server_ksa_name}]"
  ]
}
resource "google_service_account_iam_binding" "db_operator_workload_identity_binding" {
  service_account_id = google_service_account.db_operator_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.db_operator_namespace}/${var.db_operator_ksa_name}]"
  ]
}

#----NAT----
resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  network = var.network_name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.nat-router.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.gke_subnet_name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
