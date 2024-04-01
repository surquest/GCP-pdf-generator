# Introduction

This project outlines how to run On-Premise Docker Edition of https://github.com/carboneio/carbone on Google Cloud Platform (GCP) on Cloud Run service with persistent storage using Cloud Storage bucket to store permanently templates for PDF generation.

Google Cloud Platform services are managed by Terraform scripts to automate the infrastructure provisioning and configuration.

## Why Carbone on GCP?

The Carbone project is a powerful tool for generating PDFs from templates from various sources like Word, Excel, or HTML. This flexibility allows you to create complex PDFs with dynamic content and layout easily even without a knowledge of HTML and CSS. The GCP Cloud Run service is a fully managed platform that allows you to run stateless containers that are invocable via HTTP requests. This combination allows you to create a scalable and cost-effective solution for generating PDFs from templates.

All the credits for the Carbone project go to the original authors https://github.com/carboneio/carbone.

## Getting Started

Before you start deploying the PDF Generator API to GCP, you need to have the following prerequisites:

1. Adjust the configuration for GCP projects in files:

    - `config/GCP/project.env.PROD.json`
    - `config/GCP/project.env.DEV.json` - support for separating production and development environments

2. Adjust the terraform backend configuration in the `iac/terraform.tf` file.

    - `iac/GCP/backend.PROD.conf` 
    - `iac/GCP/backend.DEV.conf` - support for separating production and development environments

3. Having the Docker installed on your local machine (https://docs.docker.com/get-docker/) - is used for running the terraform scripts in the container.

4. Add the service account key file for the GCP project to the `credentials` directory.

    - `credentials/PROD/deployer.keyfile.json`
    - `credentials/DEV/deployer.keyfile.json` - support for separating production and development environments

    The service account needs to hav these permissions:

    - `roles/storage.admin` - to create and manage Cloud Storage buckets for templates and rendered PDFs
    - `roles/iam.serviceAccountAdmin` - to create and manage service account for Cloud Run service
    - `roles/run.admin` - to create and manage Cloud Run service

Once all the prerequisites are met, you can use powershell scripts `action.run.ps1` to deploy the infrastructure and the PDF Generator API to GCP.

### Repository Structure

The repository has the following structure:

```
├── config 
│   ├── solution.json                       # Solution configuration
│   ├── naming.patterns.json                # Naming patterns for resources used on Google Cloud Platform
│   └── GCP                                 # Google Cloud Platform configuration
│       ├── project.PROD.json               # GCP project information as id, name, number, region for PROD environment
│       ├── project.DEV.json                # GCP project information as id, name, number, region for DEV environment
│       └── service.json                    # Collection of configurations for GCP services
├── iac                                     # Infrastructure as Code (terraform scripts)
│   └── GCP                                 # Google Cloud Platform configuration
│       ├── backend.PROD.conf               # Terraform backend configuration for PROD environment
│       ├── backend.DEV.conf                # Terraform backend configuration for DEV environment
│       ├── main.tf                         # Main Terraform script
│       ├── iam.tf                          # Service account and IAM roles configuration
│       ├── storage.tf                      # Cloud Storage bucket configuration
│       ├── run.tf                          # Cloud Run service configuration
│       ├── var.cloud.google.env.tf         # Variables for GCP environment
│       └── var.cloud.google.services.tf    # Variables for GCP project
├── templates                               # Templates for PDF generation
│   └── proposal.docx                       # Example template for PDF generation
├── credentials                             # Service account key files
│   ├── PROD
│   │   └── deployer.keyfile.json           # TO BE CREATED for your GCP project
│   └── DEV
│       └── deployer.keyfile.json           # TO BE CREATED for your GCP project
└── action.run.ps1                          # Powershell script for deploying the infrastructure and the PDF Generator API to GCP
```

## Support

If you have any questions or need support, feel free to contact me at michal.svarc@surquest.com.

## References

* Carbone project: https://carbone.io
* Carbone Github: https://github.com/carboneio/carbone