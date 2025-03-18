variable "environment" {
  type    = string
  default = "dev"
}
variable "project_id" {
  type        = string
  description = "Project ID"
}
variable "region" {
  type        = string
  description = "region"
}
variable "gke_subnet_name" {
  type        = string
  description = "Name of the private GKE subnet fetched from output of module VPC"
}
variable "network_name" {
  type        = string
  description = "Name of the VPC fetched from output of module VPC"
}
variable "machine_type" {
  type        = string
  description = "Machine Type for the cluster"
}
variable "disk_type" {
  type        = string
  description = "Disk Type for the cluster"
}
variable "pod_ranges" {
  type        = string
  description = "Pod Ranges IP Allocation"
}
variable "service_ranges" {
  type        = string
  description = "Pod Ranges IP Allocation"
}
# K8s versions
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.30.9-gke.1201000"
}
variable "node_version" {
  type        = string
  description = "Node Version"
  default     = "1.30.9-gke.1231000"
}
#Workload Identity Binding
variable "api_server_namespace" {
  type        = string
  description = "API Server Namespace"
}
variable "api_server_ksa_name" {
  type        = string
  description = "API Server KSA Name"
}
variable "db_operator_namespace" {
  type        = string
  description = "DB Operator Namespace"

}
variable "db_operator_ksa_name" {
  type        = string
  description = "DB Operator KSA Name"
}
#CMEK
variable "gke_crypto_key_id" {
  type        = string
  description = "GKE Crypto Key ID"
}
variable "sops_crypto_key_id" {
  type        = string
  description = "SOPS Crypto Key ID"
}
variable "rotation_period" {
  type        = string
  description = "Rotation Period"
}
variable "compute_sa_email" {
  type        = string
  description = "Compute Service Account Email"

}
variable "bastion_sa_email" {
  type        = string
  description = "Bastion Service Account Email"
}
variable "key_ring_name" {
  type        = string
  description = "Key Ring Name"

}
#Bucket
variable "trace_bucket_name" {
  type        = string
  description = "Trace Bucket Name"
}

variable "backups_bucket_name" {
  type        = string
  description = "SQL Backups Bucket Name"

}