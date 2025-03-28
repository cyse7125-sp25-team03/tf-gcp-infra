output "api_server_namespace" {
  value = kubernetes_namespace.api_server.metadata[0].name
}

output "postgres_namespace" {
  value = kubernetes_namespace.postgres.metadata[0].name
}

output "operator_namespace" {
  value = kubernetes_namespace.operator_ns.metadata[0].name
}

output "backup_job_namespace" {
  value = kubernetes_namespace.backup_job_namespace.metadata[0].name
}

output "istio_system_namespace" {
  value = kubernetes_namespace.istio_system.metadata[0].name
}

output "istio_base_status" {
  value = helm_release.istio_base.status
}

output "istiod_status" {
  value = helm_release.istiod.status
}

output "istio_gateway_status" {
  value = helm_release.istio_gateway.status
}
output "prod_api_ip" {
  value = data.google_compute_address.prod_api_static_ip.address
}