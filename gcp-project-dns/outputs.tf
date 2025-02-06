output "gcp_name_servers" {
  value       = google_dns_managed_zone.gcp_csyeteam03_xyz.name_servers
  description = "Name servers for gcp.csyeteam03.xyz"
}

output "dev_name_servers" {
  value       = google_dns_managed_zone.dev_gcp_csyeteam03_xyz.name_servers
  description = "Name servers for dev.gcp.csyeteam03.xyz"
}

output "prd_name_servers" {
  value       = google_dns_managed_zone.prd_gcp_csyeteam03_xyz.name_servers
  description = "Name servers for prd.gcp.csyeteam03.xyz"
}
