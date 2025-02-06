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
  type = string
  description = "Pod Ranges IP Allocation"
}
variable "service_ranges" {
  type = string
  description = "Service Ranges IP Allocation"
}