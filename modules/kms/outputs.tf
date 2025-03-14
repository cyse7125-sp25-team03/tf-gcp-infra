output "gke_crypto_key_id" {
  description = "GKE Crypto Key ID"
  value       = google_kms_crypto_key.gke_crypto_key.id
}
output "sops_crypto_key_id" {
  description = "SOPS Crypto Key ID"
  value       = google_kms_crypto_key.sops_crypto_key.id
}
