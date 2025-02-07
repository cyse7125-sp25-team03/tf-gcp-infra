output "bastion_name" {
  description = "The name of the bastion host"
  value       = google_compute_instance.bastion.name
}

output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_sa_email" {
  description = "The email of the service account used by the bastion host"
  value       = google_service_account.bastion_sa.email
}