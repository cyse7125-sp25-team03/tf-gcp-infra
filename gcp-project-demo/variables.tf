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
variable "rotation_period" {
  type        = string
  description = "Rotation Period for the KMS key"
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
  description = "Trace Bucket Name"

}
variable "backups_bucket_name" {
  type        = string
  description = "Backups Bucket Name"

}