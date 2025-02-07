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
      subnet_region = var.region
    },
    {
      subnet_name   = "gke-subnet-${var.environment}"
      subnet_ip     = "10.2.0.0/16"
      subnet_region = var.region
    },

  ]
  secondary_ranges = {
    "gke-subnet-${var.environment}" = [
      {
        range_name    = var.service_ranges
        ip_cidr_range = "192.168.1.0/24"
      },
      {
        range_name    = var.pod_ranges
        ip_cidr_range = "192.168.64.0/22"
      }
    ]
  }
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