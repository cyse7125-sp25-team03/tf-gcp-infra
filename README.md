# Terraform GCP Infrastructure

![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5.svg?style=for-the-badge&logo=Kubernetes&logoColor=white)
![GKE](https://img.shields.io/badge/GKE-4285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689.svg?style=for-the-badge&logo=helm&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0.svg?style=for-the-badge&logo=istio&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20.svg?style=for-the-badge&logo=apache-kafka&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Cert Manager](https://img.shields.io/badge/Cert_Manager-326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Project Overview

This repository contains Terraform Infrastructure as Code (IaC) for provisioning and managing Google Cloud Platform resources across multiple environments. The infrastructure is designed to support a scalable, secure, and maintainable Kubernetes-based application platform with supporting services.

## Repository Structure

```
tf-gcp-infra/
├── charts               # Helm chart configurations
├── gcp-org              # Terraform configs for GCP organization-level resources
├── gcp-project-demo     # Terraform configs for the demo environment
├── gcp-project-dev      # Terraform configs for the development environment
├── gcp-project-dns      # Terraform configs for DNS and networking project
├── modules              # Reusable Terraform modules
│   ├── bastion          # Secure jump host configuration
│   ├── bucket           # GCS bucket configurations
│   ├── dns              # DNS configuration
│   ├── gke              # Google Kubernetes Engine cluster
│   ├── helm             # Helm release configurations
│   ├── iam              # Identity and Access Management
│   ├── kms              # Key Management Service
│   ├── monitoring       # Monitoring configurations
│   ├── secrets          # Secret management
│   └── vpc              # Virtual Private Cloud networking
└── values               # Override values for Helm charts
    ├── cert-manager-values.yaml
    ├── ingress-values.yaml
    ├── istiod-values.yaml
    ├── kafka-values.yaml
    └── postgresql-values.yaml
```

## GCP Projects

| **Directory Name**    | **Project Name in GCP**    |  
|-----------------------|----------------------------|
| `gcp-project-demo`    | csye7125-demo-project      |  
| `gcp-project-dev`     | csye7125-dev-project       |  
| `gcp-project-dns`     | csye7125-dns-project       |  

## Key Components

### Infrastructure Components

- **Google Kubernetes Engine (GKE)**: Managed Kubernetes cluster
- **VPC & Networking**: Custom network configuration with separate subnets
- **Bastion Host**: Secure VM instance for accessing private resources
- **Cloud KMS**: Key management for encryption
- **IAM**: Service accounts and permissions management
- **GCS Buckets**: Storage for traces and database backups
- **Secret Management**: For securely storing credentials

### Kubernetes Service Accounts
- API Server Service Account
- Database Backup Operator
- Trace Processor
- Trace Consumer
- Embedding Service
- Trace LLM

## Helm Charts Bootstrapped

The following Helm charts are deployed to provide core infrastructure services:

1. **cert-manager**: Certificate management for Kubernetes
2. **ingress-nginx**: Ingress controller for Kubernetes
3. **istio (istiod)**: Service mesh for microservices communication
4. **kafka**: Event streaming platform
5. **postgresql**: Relational database for persistent storage

Each chart is deployed using Terraform's Helm provider, with configurations managed through the `modules/helm` directory. The deployment process is automated and integrated with the overall infrastructure provisioning.

## Helm Values Override Files

The following values files are used to customize the Helm chart deployments:

- **cert-manager-values.yaml**: Certificate manager configuration
- **ingress-values.yaml**: NGINX ingress controller settings
- **istiod-values.yaml**: Istio service mesh configuration
- **kafka-values.yaml**: Kafka cluster settings
- **postgresql-values.yaml**: PostgreSQL database configuration

## Prerequisites

Before using this repository, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (latest version recommended)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)

## Setup and Usage

### 1. Clone the Repository

```sh
git clone https://github.com/cyse7125-sp25-team03/tf-gcp-infra.git
cd tf-gcp-infra
```

### 2. Authenticate with Google Cloud

```sh
gcloud auth login
gcloud auth application-default login
```

### 3. Select Environment

Navigate to the desired environment directory:

```sh
cd gcp-project-dev  # For development environment
# OR
cd gcp-project-demo # For demo environment
```

### 4. Configure Environment Variables

Create or modify environment-specific `.tfvars` files in the `values` directory. Below is a comprehensive example of a `.tfvars` file structure:

```hcl
# Basic project configuration
project_id  = "csye7125-demo-project"
region      = "us-east4"
environment = "demo"

# GKE cluster configuration
machine_type       = "e2-standard-2"
disk_type          = "pd-standard"
pod_ranges         = "pod-ranges"
service_ranges     = "service-ranges"
gke_subnet_ip      = "10.2.0.0/16"
public_subnet_ip   = "10.1.0.0/24"
local_ip           = "your_ip/32"
local_ip_s         = "your_ip/32"
kubernetes_version = "1.30.9-gke.1201000"
node_version       = "1.30.9-gke.1231000"
rotation_period    = "7776000s"
compute_sa_email   = "service-xxxxxxxxxxxx@compute-system.iam.gserviceaccount.com"

# Bastion host configuration
bastion_machine_type = "e2-micro"
bastion_disk_size    = 10
bastion_disk_type    = "pd-standard"
startup_script_path  = "../modules/bastion/scripts/startup_script.sh"

# KMS configuration
key_ring_name = "gke-key-ring140"

# Kubernetes Service Account mapping
api_server_namespace        = "api-server"
api_server_ksa_name         = "api-server-sa"
db_operator_namespace       = "backup-job-namespace"
db_operator_ksa_name        = "backup-sa"
trace_processor_namespace   = "trace-processor"
trace_processor_ksa_name    = "trace-processor-sa"
trace_consumer_namespace    = "trace-consumer"
trace_consumer_ksa_name     = "trace-consumer-sa"
embedding_service_namespace = "postgres"
embedding_service_ksa_name  = "embedding-service-sa"
trace_llm_namespace         = "trace-llm"
trace_llm_ksa_name          = "trace-llm-sa"

# Storage bucket configuration
trace_bucket_name   = "neu-trace-survey-bucket"
backups_bucket_name = "operator-db-backups-bucket"

# Database credentials (SENSITIVE)
postgres_username = "team03"
postgres_password = "password123"  # Use Secret Manager in production

# Docker Hub credentials (SENSITIVE)
dockerhub_username = "username"
dockerhub_password = "dckr_pat_xxxxxxxxxx"  # Use Secret Manager in production
dockerhub_email    = "user@example.com"

# Kafka credentials (SENSITIVE)
kafka_username = "team03"
kafka_password = "password123"  # Use Secret Manager in production

# API keys (SENSITIVE)
gemini_api_key = "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # Use Secret Manager in production
```

> **IMPORTANT**: The above example shows the structure of the tfvars file. Do NOT store sensitive credentials directly in the tfvars files in your repository. Use Secret Manager or encrypted configurations for production environments.

### 5. Initialize Terraform

Initialize Terraform with the appropriate backend configuration:

```sh
terraform init -backend-config="path/to/backend/vars"
```

### 6. Plan Deployment

Run a Terraform plan to preview changes:

```sh
terraform plan -var-file="../values/demo.tfvars"  # For demo environment
# OR
terraform plan -var-file="../values/dev.tfvars"   # For development environment
```

### 7. Apply Changes

Apply the Terraform configuration to create/update resources:

```sh
terraform apply -var-file="../values/demo.tfvars"  # For demo environment
# OR
terraform apply -var-file="../values/dev.tfvars"   # For development environment
```

### 8. Access Kubernetes Cluster

After resources are created, configure kubectl to access the GKE cluster:

```sh
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID
```

### 9. Handling Secrets and Sensitive Data

The infrastructure setup includes several sensitive values like database credentials, API keys, and Docker Hub tokens. Handle these securely:

1. Never commit sensitive data directly to the repository
2. Use Google Secret Manager for sensitive values
3. Consider using `sops` or `git-crypt` for encrypting sensitive tfvars files
4. For local development, keep a `.env` file with sensitive values (add to `.gitignore`)

Example of sensitive fields in tfvars:

```
# Postgres credentials
postgres_username = "username"
postgres_password = "password123"

# Docker Hub credentials
dockerhub_username = "username"
dockerhub_password = "dckr_pat_xxxxxxxxxxxx"
dockerhub_email    = "user@example.com"

# API keys
gemini_api_key = "AIzaxxxxxxxxxxxxxxxxxxxxxxx"
```

### 10. Destroy Resources (Optional)

To remove all resources created by Terraform:

```sh
terraform apply -var-file="../values/demo.tfvars"  # For demo environment
# OR
terraform apply -var-file="../values/dev.tfvars"   # For development environment
```

## Best Practices

- Use separate `.tfvars` files for different environments
- Store state in a remote backend (GCS)
- Use modules for reusable components to keep configurations DRY
- Follow the least privilege principle for IAM permissions
- Encrypt sensitive data using KMS
- Use git-crypt or similar tools for encrypting sensitive files in the repository

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Make your changes
4. Commit your changes (`git commit -m 'feat: Add some feature'`)
5. Push the branch (`git push origin feature-branch`)
6. Open a Pull Request

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.