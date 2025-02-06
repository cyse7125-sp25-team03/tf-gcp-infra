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
    type=string
    description = "Name of the private GKE subnet fetched from output of module VPC"
}
variable "network_name" {
    type=string
    description = "Name of the VPC fetched from output of module VPC"
}