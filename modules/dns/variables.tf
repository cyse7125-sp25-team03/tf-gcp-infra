variable "environment" {}
variable "project_id" {}
variable "region" {}

variable "domains" {
  description = "Mapping of environments to domains"
  type        = map(string)
  default = {
    dev  = "dev.gcp.csyeteam03.xyz."
    demo = "prd.gcp.csyeteam03.xyz."
  }
}

variable "managed_zones" {
  description = "Mapping of environments to managed zones"
  type        = map(string)
  default = {
    dev  = "dev-gcp-csyeteam03-xyz"
    demo = "prd-gcp-csyeteam03-xyz"
  }
}
