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

### 4. Initialize Terraform

Initialize Terraform with the appropriate backend configuration:

```sh
terraform init -backend-config="path/to/backend/vars"
```

### 5. Plan Deployment

Run a Terraform plan to preview changes:

```sh
terraform plan -var-file="../values/environment.tfvars"
```

### 6. Apply Changes

Apply the Terraform configuration to create/update resources:

```sh
terraform apply -var-file="../values/environment.tfvars"
```

### 7. Access Kubernetes Cluster

After resources are created, configure kubectl to access the GKE cluster:

```sh
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID
```

### 8. Destroy Resources (Optional)

To remove all resources created by Terraform:

```sh
terraform destroy -var-file="../values/environment.tfvars"
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
4. Commit your changes (`git commit -m 'Add some feature'`)
5. Push the branch (`git push origin feature-branch`)
6. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.