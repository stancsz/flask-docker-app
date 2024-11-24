# README

## Overview

This project demonstrates deploying a simple Flask application within a Docker container on a Google Cloud Platform (GCP) free-tier virtual machine (VM). The application responds with a "Hello, World!" message when accessed.

## Prerequisites

Before proceeding, ensure you have the following:

- **Google Cloud Platform Account**: Access to GCP with billing enabled.
- **Google Cloud SDK**: Installed and authenticated on your local machine.
- **Terraform**: Installed on your local machine.
- **Docker**: Installed on your local machine.

## Setup Instructions

### 1. Clone the Repository

Begin by cloning this repository to your local machine:

```bash
git clone https://github.com/yourusername/flask-docker-app.git
cd flask-docker-app
```

### 2. Configure Variables

Navigate to the `terraform/` directory and create a `terraform.tfvars` file to specify your configuration variables:

```hcl
project_id       = "your-gcp-project-id"
region           = "us-central1"
zone             = "us-central1-a"
gcs_bucket_name  = "your-unique-bucket-name"
app_archive_name = "flask-app.tar.gz"
vm_name          = "flask-docker-vm"
vm_machine_type  = "e2-micro"
```

Replace the placeholder values with your actual GCP project ID and desired configurations.

### 3. Initialize and Apply Terraform Configuration

Initialize Terraform and apply the configuration to set up the infrastructure:

```bash
terraform init
terraform apply
```

When prompted, type `yes` to confirm the creation of resources.

### 4. Access the Flask Application

After deployment, retrieve the external IP address of the VM:

```bash
gcloud compute instances list --filter="name=flask-docker-vm" --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

Access the Flask application by navigating to `http://<EXTERNAL_IP>:8080` in your web browser or by using `curl`:

```bash
curl http://<EXTERNAL_IP>:8080
```

You should receive the following JSON response:

```json
{"message": "Hello, World!"}
```

### 5. Clean Up Resources

To avoid incurring charges, clean up the resources when they are no longer needed:

```bash
terraform destroy
```

Confirm the destruction by typing `yes` when prompted.

## Notes

- **Firewall Rules**: The Terraform configuration includes a firewall rule to allow external traffic on port 8080.
- **Service Account**: A service account is created and assigned the necessary permissions for the VM to access the Google Cloud Storage bucket.
- **Startup Script**: The VM utilizes a startup script to install Docker, retrieve the Flask application from the GCS bucket, build the Docker image, and run the container.

For more detailed information, refer to the `main.tf` file in the `terraform/` directory. 