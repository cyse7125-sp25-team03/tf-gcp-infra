# Terraform Configuration for Cloud DNS

## Overview
This Terraform configuration sets up Google Cloud DNS managed zones for a root domain and its subdomains (development and production). It also configures the necessary NS records for delegating subdomain resolution.

## Prerequisites
Before using this Terraform configuration, ensure you have the following:
- A Google Cloud project with the necessary permissions to manage Cloud DNS.
- Terraform installed (version 1.0+ recommended).
- Configured authentication with GCP using a service account or gcloud CLI.

## Resources Created
- **Google Cloud DNS Managed Zone for Root Domain**
- **Google Cloud DNS Managed Zone for Development Subdomain**
- **Google Cloud DNS Managed Zone for Production Subdomain**
- **NS Records for Dev and Prod Subdomains**

## Variables
The following variables are required for this configuration:

| Variable Name         | Description                               |
|----------------------|-------------------------------------------|
| `project_id`        | Google Cloud project ID                   |
| `region`            | The GCP region for resource management     |
| `root_zone_name`    | Name of the root DNS managed zone         |
| `domain_name`       | The root domain name                      |
| `dev_zone_name`     | Name of the development subdomain zone    |
| `dev_subdomain_name`| Development subdomain (e.g., `dev.example.com.`) |
| `prod_zone_name`    | Name of the production subdomain zone     |
| `prod_subdomain_name`| Production subdomain (e.g., `prd.example.com.`) |

## Usage
1. Clone this repository and navigate to the directory containing the Terraform files.
2. Initialize Terraform:
   ```sh
   terraform init
   ```
3. Plan the deployment to see the changes:
   ```sh
   terraform plan -var="project_id=<YOUR_PROJECT_ID>" -var="region=<YOUR_REGION>"
   ```
4. Apply the configuration to create resources:
   ```sh
   terraform apply -var="project_id=<YOUR_PROJECT_ID>" -var="region=<YOUR_REGION>" -auto-approve
   ```
5. To destroy resources when no longer needed:
   ```sh
   terraform destroy -var="project_id=<YOUR_PROJECT_ID>" -var="region=<YOUR_REGION>" -auto-approve
   ```

## Notes
- The NS records for the development and production subdomains must be manually added to the root domain's registrar settings.
- Ensure that the project has Cloud DNS API enabled before applying the configuration.
