# tf-gcp-infra
## Project Structure
```
tf-gcp-infra/
├── gcp-org             # Terraform configs for GCP organization-level resources
├── gcp-project-demo    # Terraform configs for the demo environment
├── gcp-project-dev     # Terraform configs for the development environment
├── gcp-project-dns     # Terraform configs for DNS and networking project
└── modules             # Reusable Terraform modules
```
This repository contains Terraform code for the following projects in GCP:

| **Directory Name**       | **Project Name in GCP**         |  
|----------------------|------------------------| 
| `gcp-project-demo`  | csye7125-demo-project           |  
| `gcp-project-dev`   | csye7125-dev-project     |  
| `gcp-project-dns`   | csye7125-dns-project  |  

## **Prerequisites**  

Ensure you have the following installed:  
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (latest version recommended)  
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)  

## Usage

### 1. Initialize Terraform
Navigate to the desired environment directory and initialize Terraform:
```sh
cd gcp-project-dev  # Change directory to the environment you want to deploy
terraform init -backend-config="path/to/backend/vars"
```

### 2. Plan Deployment
Run a Terraform plan to preview changes:
```sh
terraform plan
```

### 3. Apply Changes
Apply the Terraform configuration to create/update resources:
```sh
terraform apply
```

### 4. Destroy Resources (Optional)
To remove all resources created by Terraform:
```sh
terraform destroy
```

## Best Practices
- Use separate `tfvars` files for different environments.
- Use modules for reusable components to keep configurations DRY.

## Contributing
1. Fork the repository.
2. Create a new branch (`feature-branch`).
3. Commit your changes.
4. Push the branch and open a Pull Request.