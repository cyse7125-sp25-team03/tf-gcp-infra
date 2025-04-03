resource "google_project_service" "compute_demo" {
  project            = var.demo_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "gke_demo" {
  project            = var.demo_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "binary_auth_demo" {
  project            = var.demo_project_id
  service            = "binaryauthorization.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "iamcredentials_demo" {
  project            = var.demo_project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "kms_demo" {
  project            = var.demo_project_id
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "secretmanager_demo" {
  project            = var.demo_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging_demo" {
  project            = var.demo_project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "monitoring_demo" {
  project            = var.demo_project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager_demo" {
  project            = var.demo_project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "stackdriver_demo" {
  project            = var.demo_project_id
  service            = "stackdriver.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_demo" {
  project            = var.demo_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}
