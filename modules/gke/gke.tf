#----gke pre-reqs----
resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa-id"
  display_name = "Service Account for GKE"
}

data "google_compute_zones" "available_zones" {
  region = var.region
}
#----GKE Cluster----
resource "google_container_cluster" "gke_cluster" {
  name           = "gke-cluster-${var.environment}"
  location       = var.region
  node_locations = slice(data.google_compute_zones.available_zones.names, 0, 2)
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
    enable_private_endpoint = true
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
  node_locations = slice(data.google_compute_zones.available_zones.names, 0, 2)
  #multizone (first two available zones list)
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 1 #nodes per zone
  version    = var.node_version

  node_config {
    preemptible  = true
    machine_type = var.machine_type #Defaults to e2-medium
    image_type   = "COS_CONTAINERD"
    disk_size_gb = 50 #Defaults to 100
    disk_type    = var.disk_type

    # required to enable workload identity on node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
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
