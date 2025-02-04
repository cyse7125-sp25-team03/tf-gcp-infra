resource "google_project_service" "compute_demo" {
  project = var.demo_project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}