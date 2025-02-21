terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

# Provider for DNS project
provider "google" {
  alias   = "root"
  project = var.dns_project_id
  region  = var.region
}

# Provider for dev project
provider "google" {
  alias   = "dev"
  project = var.dev_project_id
  region  = var.region
}

# Provider for demo project
provider "google" {
  alias   = "prod"
  project = var.prod_project_id
  region  = var.region
}

# Cloud DNS Managed Zone for root domain in DNS project
resource "google_dns_managed_zone" "gcp_csyeteam03_xyz" {
  provider    = google.root
  name        = var.root_zone_name
  dns_name    = var.root_domain_name
  description = "DNS zone for ${var.root_domain_name}"
  visibility  = "public"
  labels = {
    environment = "root"
  }
}

# Cloud DNS Managed Zone for dev subdomain in DEV project
resource "google_dns_managed_zone" "dev_gcp_csyeteam03_xyz" {
  provider    = google.dev
  name        = var.dev_zone_name
  dns_name    = var.dev_subdomain_name
  description = "DNS zone for ${var.dev_subdomain_name}"
  visibility  = "public"
  labels = {
    environment = "development"
  }
}

# Cloud DNS Managed Zone for prod subdomain in DEMO project
resource "google_dns_managed_zone" "prd_gcp_csyeteam03_xyz" {
  provider    = google.prod
  name        = var.prod_zone_name
  dns_name    = var.prod_subdomain_name
  description = "DNS zone for ${var.prod_subdomain_name}"
  visibility  = "public"
  labels = {
    environment = "production"
  }
}

# NS records for dev subdomain in root domain (DNS project)
resource "google_dns_record_set" "dev_ns" {
  provider     = google.root
  name         = var.dev_subdomain_name
  managed_zone = google_dns_managed_zone.gcp_csyeteam03_xyz.name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.dev_gcp_csyeteam03_xyz.name_servers
}

# NS records for prod subdomain in root domain (DNS project)
resource "google_dns_record_set" "prd_ns" {
  provider     = google.root
  name         = var.prod_subdomain_name
  managed_zone = google_dns_managed_zone.gcp_csyeteam03_xyz.name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.prd_gcp_csyeteam03_xyz.name_servers
}