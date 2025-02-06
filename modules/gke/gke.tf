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

}
#----GKE Node Pool----
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name           = "node-pool-${var.environment}"
  location       = var.region #Regional
  node_locations = slice(data.google_compute_zones.available_zones.names, 0, 2)
  #multizone (first two available zones list)
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 1 #nodes per zone

  node_config {
    preemptible  = true
    machine_type = var.machine_type #Defaults to e2-medium
    image_type   = "COS_CONTAINERD"
    disk_size_gb = 10 #Defaults to 100
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