variable "demo_project_id" {
  type        = string
  description = "Demo Project ID"
}
variable "dev_project_id" {
  type        = string
  description = "Dev Project ID"
}
variable "dns_project_id" {
  type        = string
  description = "DNS Project ID"
}
variable "region" {
  type        = string
  default     = "us-east1"
  description = "Region"
}