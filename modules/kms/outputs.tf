output "gke_crypto_key_id" {
  description = "GKE Crypto Key ID"
  value       = google_kms_crypto_key.gke_crypto_key.id
}
