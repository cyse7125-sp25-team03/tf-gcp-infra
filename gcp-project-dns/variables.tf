variable "dns_project_id" {
  description = "GCP DNS project ID"
  type        = string
}

variable "dev_project_id" {
  description = "GCP DEV project ID"
  type        = string
}

variable "prod_project_id" {
  description = "GCP DEMO project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-east1"
}

variable "root_zone_name" {
  description = "Root zone name"
  type        = string
}

variable "dev_zone_name" {
  description = "Dev zone name"
  type        = string
}

variable "prod_zone_name" {
  description = "Prod zone name"
  type        = string
}

variable "root_domain_name" {
  description = "Root domain name"
  type        = string
}

variable "dev_subdomain_name" {
  description = "Development subdomain name"
  type        = string
}

variable "prod_subdomain_name" {
  description = "Production subdomain name"
  type        = string
}
#dev_api_server_subdomain_name
variable "dev_api_server_subdomain_name" {
  description = "Development API server subdomain name"
  type        = string
}
#prd_api_server_subdomain_name
variable "prod_api_server_subdomain_name" {
  description = "Production API server subdomain name"
  type        = string
}
