# cert-manager
resource "google_service_account" "cert_manager" {
  account_id   = "cert-manager"
  display_name = "cert-manager CloudDNS Service Account"
}
resource "google_project_iam_binding" "cert_manager_dns" {
  project = var.project_id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.cert_manager.email}",
  ]
}
resource "google_service_account_iam_binding" "cert_manager_wi" {
  service_account_id = google_service_account.cert_manager.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
  ]
}

