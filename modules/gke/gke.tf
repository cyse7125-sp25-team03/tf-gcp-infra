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
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "monitoring_reader" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
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

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }
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
      display_name = "Developer 1 IP"
    }
    cidr_blocks {
      cidr_block   = var.local_ip_s # Local IP CIDR
      display_name = "Developer 2 IP"
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

# Add a new node pool with n2-standard-4
resource "google_container_node_pool" "high_performance_nodes" {
  name           = "high-perf-node-pool-${var.environment}"
  location       = var.region
  node_locations = [data.google_compute_zones.available_zones.names[2]] # Use just the 3rd zone
  cluster        = google_container_cluster.gke_cluster.name
  node_count     = 1 # 1 node in this zone
  version        = var.node_version

  node_config {
    preemptible       = true
    machine_type      = "n2-standard-4" # Higher performance machine
    image_type        = "COS_CONTAINERD"
    disk_size_gb      = 50
    disk_type         = "pd-standard" # Consider using SSD for better performance
    service_account   = google_service_account.gke_sa.email
    boot_disk_kms_key = var.gke_crypto_key_id

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Optional: Add labels or taints to ensure your RAG workloads run on this node
    labels = {
      "node-type" = "high-performance"
    }

    # If you want to ensure only your RAG workloads run on this node:
    taint {
      key    = "dedicated"
      value  = "rag"
      effect = "NO_SCHEDULE"
    }
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
resource "google_service_account" "trace_processor_gsa" {
  account_id   = "trace-processor-gsa"
  display_name = "GSA for Trace Processor Workload Identity"
}
resource "google_service_account" "trace_consumer_gsa" {
  account_id   = "trace-consumer-gsa"
  display_name = "GSA for Trace Consumer Workload Identity"
}
resource "google_service_account" "embedding_service_gsa" {
  account_id   = "embedding-service-gsa"
  display_name = "GSA for Trace Embedding Service Workload Identity"
}
resource "google_service_account" "trace_llm_gsa" {
  account_id   = "trace-llm-gsa"
  display_name = "GSA for Trace LLM Workload Identity"
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

resource "google_project_iam_member" "secrets_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.workload_identity_gsa.email}"
}

resource "google_project_iam_member" "storage_access_db_operator" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.db_operator_gsa.email}"
}

resource "google_project_iam_member" "secrets_access_db_operator" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.db_operator_gsa.email}"
}

resource "google_project_iam_member" "storage_access_trace_processor" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.trace_processor_gsa.email}"
}

resource "google_project_iam_member" "secrets_access_trace_processor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.trace_processor_gsa.email}"
}

resource "google_project_iam_member" "secrets_access_trace_consumer" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.trace_consumer_gsa.email}"
}

resource "google_project_iam_member" "secrets_access_embedding_service" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.embedding_service_gsa.email}"
}

resource "google_project_iam_member" "secrets_access_trace_llm" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.trace_llm_gsa.email}"
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
resource "google_service_account_iam_binding" "trace_processor_workload_identity_binding" {
  service_account_id = google_service_account.trace_processor_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.trace_processor_namespace}/${var.trace_processor_ksa_name}]"
  ]
}
resource "google_service_account_iam_binding" "trace_consumer_workload_identity_binding" {
  service_account_id = google_service_account.trace_consumer_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.trace_consumer_namespace}/${var.trace_consumer_ksa_name}]"
  ]
}
resource "google_service_account_iam_binding" "embedding_service_workload_identity_binding" {
  service_account_id = google_service_account.embedding_service_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.embedding_service_namespace}/${var.embedding_service_ksa_name}]"
  ]
}
resource "google_service_account_iam_binding" "trace_llm_workload_identity_binding" {
  service_account_id = google_service_account.trace_llm_gsa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.trace_llm_namespace}/${var.trace_llm_ksa_name}]"
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
