resource "google_project_service" "compute_dev" {
  project = var.dev_project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gke_dev" {
  project = var.dev_project_id
  service = "container.googleapis.com"
  disable_on_destroy = false
}
