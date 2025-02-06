terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud DNS Managed Zone for root domain
resource "google_dns_managed_zone" "gcp_csyeteam03_xyz" {
  name        = var.root_zone_name
  dns_name    = var.domain_name
  description = "DNS zone for ${var.domain_name}"

  visibility = "public"

  labels = {
    environment = "root"
  }
}

# Cloud DNS Managed Zone for dev subdomain
resource "google_dns_managed_zone" "dev_gcp_csyeteam03_xyz" {
  name        = var.dev_zone_name
  dns_name    = var.dev_subdomain_name
  description = "DNS zone for ${var.dev_subdomain_name}"

  visibility = "public"

  labels = {
    environment = "development"
  }
}

# Cloud DNS Managed Zone for prod subdomain
resource "google_dns_managed_zone" "prd_gcp_csyeteam03_xyz" {
  name        = var.prod_zone_name
  dns_name    = var.prod_subdomain_name
  description = "DNS zone for ${var.prod_subdomain_name}"

  visibility = "public"

  labels = {
    environment = "production"
  }
}

# NS records for dev subdomain
resource "google_dns_record_set" "dev_ns" {
  name         = var.dev_subdomain_name
  managed_zone = google_dns_managed_zone.gcp_csyeteam03_xyz.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.dev_gcp_csyeteam03_xyz.name_servers
}

# NS records for prod subdomain
resource "google_dns_record_set" "prd_ns" {
  name         = var.prod_subdomain_name
  managed_zone = google_dns_managed_zone.gcp_csyeteam03_xyz.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.prd_gcp_csyeteam03_xyz.name_servers
}