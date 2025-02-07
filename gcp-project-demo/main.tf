module "vpc" {
  source         = "../modules/vpc"
  project_id     = var.project_id
  environment    = var.environment
  region         = var.region
  pod_ranges     = var.pod_ranges
  service_ranges = var.service_ranges
}
module "gke" {
  depends_on      = [module.vpc]
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

module "bastion" {
  depends_on           = [module.vpc]
  source               = "../modules/bastion"
  project_id           = var.project_id
  environment          = var.environment
  region               = var.region
  network_name         = module.vpc.network_name
  public_subnet_name   = "public-subnet-${var.environment}"
  bastion_machine_type = var.bastion_machine_type
  bastion_disk_size    = var.bastion_disk_size
  bastion_disk_type    = var.bastion_disk_type
  startup_script_path  = var.startup_script_path
}