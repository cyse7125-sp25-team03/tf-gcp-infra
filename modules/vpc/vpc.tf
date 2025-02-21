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
      subnet_ip     = var.public_subnet_ip
      subnet_region = var.region
    },
    {
      subnet_name   = "gke-subnet-${var.environment}"
      subnet_ip     = var.gke_subnet_ip
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

resource "google_compute_firewall" "deny-all-to-gke-subnet" {
  project     = var.project_id
  name        = "deny-all-to-gke-subnet"
  network     = module.vpc.network_name
  description = "Deny all access to the GKE subnet from outside sources"

  deny {
    protocol = "all"
  }

  destination_ranges = [var.gke_subnet_ip]
  source_ranges      = ["0.0.0.0/0"]
  priority           = 1001
}
resource "google_compute_firewall" "allow-ssh-to-gke-subnet" {
  project     = var.project_id
  name        = "allow-bastion-to-gke-subnet"
  network     = module.vpc.network_name
  description = "Allow access to the GKE subnet from the bastion VM"

  allow {
    protocol = "tcp"
  }

  source_tags        = ["ssh-vm"] # Only from bastion with this tag
  destination_ranges = [var.gke_subnet_ip]
  priority           = 1000
}