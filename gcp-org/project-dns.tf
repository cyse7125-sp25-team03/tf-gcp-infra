resource "google_project_service" "cloud_dns" {
  project            = var.dns_project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}
