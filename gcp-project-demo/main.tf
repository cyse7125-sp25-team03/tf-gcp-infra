module "vpc" {
  source           = "../modules/vpc"
  project_id       = var.project_id
  environment      = var.environment
  region           = var.region
  pod_ranges       = var.pod_ranges
  service_ranges   = var.service_ranges
  gke_subnet_ip    = var.gke_subnet_ip
  public_subnet_ip = var.public_subnet_ip
}
module "gke" {
  depends_on           = [module.vpc, module.kms]
  source               = "../modules/gke"
  project_id           = var.project_id
  environment          = var.environment
  region               = var.region
  gke_subnet_name      = module.vpc.gke_subnet_name
  network_name         = module.vpc.network_name
  machine_type         = var.machine_type
  disk_type            = var.disk_type
  pod_ranges           = var.pod_ranges
  service_ranges       = var.service_ranges
  gke_subnet_ip        = var.gke_subnet_ip
  public_subnet_ip     = var.public_subnet_ip
  kubernetes_version   = var.kubernetes_version
  node_version         = var.node_version
  gke_crypto_key_id    = module.kms.gke_crypto_key_id
  sops_crypto_key_id   = module.kms.sops_crypto_key_id
  compute_sa_email     = var.compute_sa_email
  bastion_sa_email     = module.bastion.bastion_sa_email
  api_server_namespace = var.api_server_namespace
  api_server_ksa_name  = var.api_server_ksa_name
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

module "kms" {
  source          = "../modules/kms"
  region          = var.region
  rotation_period = var.rotation_period
  key_ring_name   = var.key_ring_name
}

module "bucket" {
  source              = "../modules/bucket"
  region              = var.region
  trace_bucket_name   = var.trace_bucket_name
  backups_bucket_name = var.backups_bucket_name
}
