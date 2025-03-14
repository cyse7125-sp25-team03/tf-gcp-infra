resource "google_kms_key_ring" "gke_key_ring" {
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "gke_crypto_key" {
  name     = "gke-encryption-key"
  key_ring = google_kms_key_ring.gke_key_ring.id

  rotation_period = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }
}



