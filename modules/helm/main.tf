# Activate cluster credentials using null_resource and local-exec
resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region=${var.region} --project=${var.project_id}"
  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [null_resource.get_credentials]
}

# Install Istio base chart
resource "helm_release" "istio_base" {
  name      = "istio-base"
  chart     = "${path.module}/../../charts/base"
  namespace = "istio-system"

  depends_on = [kubernetes_namespace.istio_system]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
}

# Install Istiod chart with custom values
resource "helm_release" "istiod" {
  name      = "istiod"
  chart     = "${path.module}/../../charts/istiod"
  namespace = "istio-system"

  # Use custom values file for Istiod
  values = [file("${path.module}/../../values/istiod-values.yaml")]

  depends_on = [helm_release.istio_base]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
}

# Install Istio gateway
resource "helm_release" "istio_gateway" {
  name      = "istio-gateway"
  chart     = "${path.module}/../../charts/gateway"
  namespace = "istio-system"

  depends_on = [helm_release.istiod]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
}

# Create namespaces
resource "kubernetes_namespace" "api_server" {
  metadata {
    name = "api-server"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      istio-injection = "disabled" # Exclude PostgreSQL from istio
    }
  }

  depends_on = [null_resource.get_credentials]
}

resource "kubernetes_namespace" "operator_ns" {
  metadata {
    name = "operator-ns"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
}

resource "kubernetes_namespace" "backup_job_namespace" {
  metadata {
    name = "backup-job-namespace"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
}

# Install Postgreasql chart
resource "helm_release" "postgres" {
  name      = "pg"
  chart     = "${path.module}/../../charts/postgresql"
  namespace = "postgres"

  # Use custom values file for Istiod
  values = [file("${path.module}/../../values/postgresql-values.yaml")]

  depends_on = [kubernetes_namespace.postgres]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
}