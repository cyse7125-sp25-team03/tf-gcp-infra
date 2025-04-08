# Activate cluster credentials using null_resource and local-exec
resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region=${var.region} --project=${var.project_id}"
  }
}

resource "null_resource" "apply_cert_manager_crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml"
  }

  depends_on = [null_resource.get_credentials]
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Install Istio base chart
resource "helm_release" "istio_base" {
  name      = "istio-base"
  chart     = "${path.module}/../../charts/base"
  namespace = "istio-system"

  depends_on = [kubernetes_namespace.istio_system]
  # lifecycle {
  #   prevent_destroy = true
  # }

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
}

# Install Istiod chart with custom values
resource "helm_release" "istiod" {
  name      = "istiod"
  chart     = "${path.module}/../../charts/istiod"
  namespace = "istio-system"
  # lifecycle {
  #   prevent_destroy = true
  # }
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
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Create namespaces
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "kubernetes_namespace" "api_server" {
  metadata {
    name = "api-server"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      istio-injection = "disabled" # Exclude PostgreSQL from istio
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "kubernetes_namespace" "operator_ns" {
  metadata {
    name = "operator-ns"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "kubernetes_namespace" "backup_job_namespace" {
  metadata {
    name = "backup-job-namespace"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "helm_release" "external_secrets" {
  name      = "external-secrets"
  chart     = "${path.module}/../../charts/external-secrets"
  namespace = "external-secrets"

  depends_on = [kubernetes_namespace.external_secrets]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
  # lifecycle {
  #   prevent_destroy = true
  # }
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
  # lifecycle {
  #   prevent_destroy = true
  # }
}
#create namespace called cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  chart     = "${path.module}/../../charts/cert-manager"
  namespace = "cert-manager"

  depends_on = [kubernetes_namespace.cert_manager]
  values     = [file("${path.module}/../../values/cert-manager-values.yaml")]
  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
  # lifecycle {
  #   prevent_destroy = true
  # }

}
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  chart      = "${path.module}/../../charts/ingress-nginx"
  depends_on = [kubernetes_namespace.ingress_nginx]

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.api_server_ip
  }
  values = [file("${path.module}/../../values/ingress-values.yaml")]
  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Create namespace for Kafka
resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [null_resource.get_credentials]
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Install Bitnami Kafka chart
resource "helm_release" "kafka" {
  name      = "kafka"
  chart     = "${path.module}/../../charts/kafka"
  namespace = "kafka"

  # Use custom values file for Kafka configuration
  values = [file("${path.module}/../../values/kafka-values.yaml")]

  depends_on = [kubernetes_namespace.kafka]

  # Force helm to wait until all resources are deployed successfully
  wait    = true
  timeout = 300
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "kubernetes_secret" "dockerhub_secret_api_server" {
  metadata {
    name      = "dockerhub-secret"
    namespace = "api-server"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          "username" = var.dockerhub_username
          "password" = var.dockerhub_password
          "email"    = var.dockerhub_email
          "auth"     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.api_server]
}

resource "kubernetes_secret" "dockerhub_secret_operator_ns" {
  metadata {
    name      = "dockerhub-secret"
    namespace = "operator-ns"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          "username" = var.dockerhub_username
          "password" = var.dockerhub_password
          "email"    = var.dockerhub_email
          "auth"     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.operator_ns]
}
