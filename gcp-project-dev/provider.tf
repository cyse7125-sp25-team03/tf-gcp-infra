provider "google" {
  project = var.project_id
  region  = var.region
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Create a data source to get GKE cluster info
data "google_container_cluster" "gke_cluster" {
  name     = module.gke.cluster_name
  location = var.region
  project  = var.project_id

  depends_on = [module.gke]
}

# Configure kubernetes provider with explicit auth
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

# Configure helm provider with explicit auth
provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
  }
}

# Get the Google client config for token
data "google_client_config" "current" {}