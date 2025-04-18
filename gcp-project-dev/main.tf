module "vpc" {
  source           = "../modules/vpc"
  project_id       = var.project_id
  environment      = var.environment
  region           = var.region
  pod_ranges       = var.pod_ranges
  service_ranges   = var.service_ranges
  gke_subnet_ip    = var.gke_subnet_ip
  public_subnet_ip = var.public_subnet_ip
  local_ip         = var.local_ip
  local_ip_s       = var.local_ip_s
}
module "gke" {
  depends_on                  = [module.vpc, module.kms, module.iam, module.dns]
  source                      = "../modules/gke"
  project_id                  = var.project_id
  environment                 = var.environment
  region                      = var.region
  gke_subnet_name             = module.vpc.gke_subnet_name
  network_name                = module.vpc.network_name
  machine_type                = var.machine_type
  disk_type                   = var.disk_type
  pod_ranges                  = var.pod_ranges
  service_ranges              = var.service_ranges
  gke_subnet_ip               = var.gke_subnet_ip
  public_subnet_ip            = var.public_subnet_ip
  local_ip                    = var.local_ip
  local_ip_s                  = var.local_ip_s
  kubernetes_version          = var.kubernetes_version
  node_version                = var.node_version
  gke_crypto_key_id           = module.kms.gke_crypto_key_id
  sops_crypto_key_id          = module.kms.sops_crypto_key_id
  compute_sa_email            = var.compute_sa_email
  bastion_sa_email            = module.bastion.bastion_sa_email
  api_server_namespace        = var.api_server_namespace
  api_server_ksa_name         = var.api_server_ksa_name
  db_operator_namespace       = var.db_operator_namespace
  db_operator_ksa_name        = var.db_operator_ksa_name
  trace_processor_namespace   = var.trace_processor_namespace
  trace_processor_ksa_name    = var.trace_processor_ksa_name
  trace_consumer_namespace    = var.trace_consumer_namespace
  trace_consumer_ksa_name     = var.trace_consumer_ksa_name
  embedding_service_namespace = var.embedding_service_namespace
  embedding_service_ksa_name  = var.embedding_service_ksa_name
  trace_llm_namespace         = var.trace_llm_namespace
  trace_llm_ksa_name          = var.trace_llm_ksa_name
  cluster_name                = module.gke.cluster_name
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

module "secrets" {
  source = "../modules/secrets"

  project_id        = var.project_id
  region            = var.region
  postgres_username = var.postgres_username
  postgres_password = var.postgres_password
  kafka_username    = var.kafka_username
  kafka_password    = var.kafka_password
  gemini_api_key    = var.gemini_api_key

  depends_on = [module.gke, module.bastion]
}

module "helm" {
  source = "../modules/helm"

  project_id         = var.project_id
  region             = var.region
  cluster_name       = module.gke.cluster_name
  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  dockerhub_email    = var.dockerhub_email
  api_server_ip      = module.dns.api_server_ip

  depends_on = [module.gke, module.bastion]
}

module "iam" {
  source = "../modules/iam"

  project_id = var.project_id
  region     = var.region
}
module "dns" {
  source = "../modules/dns"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment


}
module "monitoring" {
  source     = "../modules/monitoring"
  depends_on = [module.gke, module.helm]
}