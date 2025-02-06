variable "project_id" {
  description = "GCP project ID"
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

variable "domain_name" {
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
