output "api_server_ip" {
  value       = google_compute_address.api_static_ip.address
  description = "Static IP address for the API server"
}