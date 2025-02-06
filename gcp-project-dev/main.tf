module "vpc" {
  source         = "../modules/vpc"
  project_id     = var.project_id
  environment    = var.environment
  region         = var.region
  pod_ranges     = var.pod_ranges
  service_ranges = var.service_ranges
}
module "gke" {
  source          = "../modules/gke"
  project_id      = var.project_id
  environment     = var.environment
  region          = var.region
  gke_subnet_name = module.vpc.gke_subnet_name
  network_name    = module.vpc.network_name
  machine_type    = var.machine_type
  disk_type       = var.disk_type
  pod_ranges      = var.pod_ranges
  service_ranges  = var.service_ranges
}