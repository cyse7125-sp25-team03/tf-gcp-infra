# Get available zones in the region
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-sa-${var.environment}"
  display_name = "Service Account for Bastion Host"
  project      = var.project_id
}

resource "google_compute_instance" "bastion" {
  name         = "bastion-${var.environment}"
  machine_type = var.bastion_machine_type
  zone         = data.google_compute_zones.available.names[0]
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.bastion_disk_size
      type  = var.bastion_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.public_subnet_name

    // This will ensure the instance gets a public IP
    access_config {
      // Ephemeral public IP
    }
  }

  // Install gcloud cli and kubectl
  metadata_startup_script = file(var.startup_script_path)

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["cloud-platform"]
  }

  tags = ["ssh-vm"]

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

# IAM role binding for GKE access
resource "google_project_iam_member" "bastion_gke_admin" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.bastion_sa.email}"
}