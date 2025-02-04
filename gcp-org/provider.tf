provider "google" {
  project = var.demo_project_id
  region  = var.region
  alias   = "demo"
}
provider "google" {
  project = var.dev_project_id
  region  = var.region
  alias   = "dev"
}
provider "google" {
  project = var.dns_project_id
  region  = var.region
  alias   = "dns"
}

