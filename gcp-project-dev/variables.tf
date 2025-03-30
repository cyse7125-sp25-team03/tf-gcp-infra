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
  description = "Service Ranges IP Allocation"
}
variable "bastion_machine_type" {
  type        = string
  description = "The machine type for the bastion host"
}
variable "bastion_disk_size" {
  type        = number
  description = "Boot disk size in GB"
}
variable "bastion_disk_type" {
  type        = string
  description = "Boot disk type"
}
variable "startup_script_path" {
  type        = string
  description = "Path to the bastion host startup script"
  default     = "../modules/bastion/scripts/startup_script.sh"
}
variable "gke_subnet_ip" {
  type        = string
  description = "GKE Subnet IP Allocation"
}
variable "public_subnet_ip" {
  type        = string
  description = "Public Subnet IP Allocation"
}
variable "local_ip" {
  type        = string
  description = "Developer 1 IP Allocation"
}
variable "local_ip_s" {
  type        = string
  description = "Developer 2 IP Allocation"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
}
variable "node_version" {
  type        = string
  description = "Node Version"
}
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
variable "rotation_period" {
  type        = string
  description = "Rotation period for the KMS key"
}
variable "compute_sa_email" {
  type        = string
  description = "Compute Service Account Email"
}
variable "key_ring_name" {
  type        = string
  description = "Key Ring Name"

}
variable "trace_bucket_name" {
  type        = string
  description = "Bucket Name"

}
variable "backups_bucket_name" {
  type        = string
  description = "Bucket Name"

}
variable "postgres_username" {
  type        = string
  description = "Postgres Username"
}
variable "postgres_password" {
  type        = string
  description = "Postgres Password"
}
variable "dockerhub_username" {
  description = "DockerHub username"
  type        = string
}

variable "dockerhub_password" {
  description = "DockerHub password"
  type        = string
  sensitive   = true
}

variable "dockerhub_email" {
  description = "DockerHub email"
  type        = string
}
