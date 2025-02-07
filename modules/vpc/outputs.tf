output "network_name" {
  value = module.vpc.network_name
}

output "public_subnet_name" {
  value = "public-subnet-${var.environment}"
}

output "gke_subnet_name" {
  value = "gke-subnet-${var.environment}"
}
