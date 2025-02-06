# GCP Organization
This folder contains Terraform Code for the GCP Organization `csyeteam03.xyz`

## Project Structure

This Terraform configuration is organized into separate files by GCP projects in the organization.

### Folder Structure

```
gcp-org/
│── main.tf                # Main Terraform configuration file
│── project-demo.tf        # Configuration for Demo Project
│── project-dev.tf         # Configuration for Dev Project
│── project-dns.tf         # Configuration for DNS Project
│── provider.tf            # Provider Configurations
│── variables.tf           # Variable Definitions
```

### Files Overview:

**`main.tf`**  
   Contains the overall configuration for Terraform, including provider definitions. This file is used to initialize the required provider (`google` in this case) and specify the version.

**`project-X.tf`**  
   The `project-X.tf` files contain configurations specific to respective projects; `csye7125-dev`, `csye7125-demo`, `csye7125-dns`. The files include a list of APIs enabled on the projects.

**`provider.tf`**  
   Centralizes the provider configurations for all Google Cloud projects.

**`variables.tf`**  
    Defines all input variables used across the Terraform configuration.
