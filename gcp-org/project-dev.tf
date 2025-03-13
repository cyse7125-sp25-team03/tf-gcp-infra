resource "google_project_service" "compute_dev" {
  project            = var.dev_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gke_dev" {
  project            = var.dev_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "binary_auth_dev" {
  project            = var.dev_project_id
  service            = "binaryauthorization.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "iamcredentials_dev" {
  project            = var.dev_project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "kms_dev" {
  project            = var.dev_project_id
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}
