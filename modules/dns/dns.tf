#api-server
data "google_dns_managed_zone" "selected_zone" {
  name = lookup(var.managed_zones, var.environment, var.managed_zones["demo"])
}

resource "google_compute_address" "api_static_ip" {
  name   = "${var.environment}-server-static-ip"
  region = var.region

}

resource "google_dns_record_set" "api_dns" {
  name         = "api-server.${var.domains[var.environment]}"
  managed_zone = data.google_dns_managed_zone.selected_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.api_static_ip.address]
}

resource "google_dns_record_set" "trace_llm_dns" {
  name         = "asktrace.${var.domains[var.environment]}"
  managed_zone = data.google_dns_managed_zone.selected_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.api_static_ip.address]
}

