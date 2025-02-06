module "vpc" {
  source                  = "terraform-google-modules/network/google"
  version                 = "~> 10.0"
  auto_create_subnetworks = false
  project_id              = var.project_id
  network_name            = "gke-vpc-${var.environment}"
  routing_mode            = "REGIONAL"

  subnets = [
    {
      subnet_name   = "public-subnet-${var.environment}"
      subnet_ip     = "10.1.0.0/24"
      subnet_region = "us-east1"
    },
    {
      subnet_name   = "private-subnet-${var.environment}"
      subnet_ip     = "10.1.1.0/24"
      subnet_region = "us-east1"
    },
    {
      subnet_name   = "gke-subnet-${var.environment}"
      subnet_ip     = "10.2.0.0/16"
      subnet_region = "us-east1"
    },

  ]
  secondary_ranges = {
    "gke-subnet-${var.environment}" = [
      {
        range_name    = "service-ranges"
        ip_cidr_range = "192.168.1.0/24"
      },
      {
        range_name    = "pod-ranges"
        ip_cidr_range = "192.168.64.0/22"
      }
    ]
  }
  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "igw" #NOTE: attach this tag for public subnet access
      next_hop_internet = "true"
    },
  ]

}

resource "google_compute_firewall" "allow-ssh" {
  project     = var.project_id
  name        = "allow-ssh-to-vm"
  network     = module.vpc.network_name
  description = "Creates firewall rule targeting tagged instances to allow ssh"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-vm"] #NOTE: attach this tagto vm for ssh access
  source_ranges = ["0.0.0.0/0"]
}