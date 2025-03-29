output "cluster_name" {
  value       = google_container_cluster.gke_cluster.name
  description = "GKE cluster name"
}
output "api_sa_email" {
  value       = google_service_account.workload_identity_gsa.email
  description = "api-server service account email"
}