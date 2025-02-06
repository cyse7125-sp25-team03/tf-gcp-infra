module "vpc" {
  source = "../modules/vpc"
  project_id = var.project_id
  environment = var.environment
  region = var.region
}
module "gke" {
  source = "../modules/gke"
  project_id = var.project_id
  environment = var.environment
  region = var.region
  gke_subnet_name   = module.vpc.gke_subnet_name
  network_name     = module.vpc.network_name
}