provider "google" {
  project = var.project_id
  region  = var.region
}

# Step 1: Create the GCS bucket
resource "google_storage_bucket" "flask_app_bucket" {
  name          = var.gcs_bucket_name
  location      = var.region
  storage_class = "STANDARD"
}

# Step 2: Create a tarball of the app using `local-exec`
resource "null_resource" "package_app" {
  provisioner "local-exec" {
    command = "tar -czf ${path.module}/${var.app_archive_name} -C ${path.module}/../app ."
  }
}

# Step 3: Upload the Flask app tarball to GCS
resource "google_storage_bucket_object" "flask_app" {
  depends_on = [null_resource.package_app, google_storage_bucket.flask_app_bucket] # Ensure the tarball and bucket are created first
  name       = var.app_archive_name
  bucket     = google_storage_bucket.flask_app_bucket.name
  source     = "${path.module}/${var.app_archive_name}"
}

# Cleanup step: Remove local tarball after upload
resource "null_resource" "cleanup_local_tarball" {
  depends_on = [google_storage_bucket_object.flask_app]

  provisioner "local-exec" {
    command = "rm -f ${path.module}/${var.app_archive_name}"
  }
}

# Step 4: Create a service account for the VM
resource "google_service_account" "vm_service_account" {
  account_id   = "${var.vm_name}-sa"
  display_name = "Service Account for ${var.vm_name}"
}

# Grant bucket-specific access to the service account
resource "google_storage_bucket_iam_member" "flask_app_bucket_access" {
  bucket     = google_storage_bucket.flask_app_bucket.name
  role       = "roles/storage.objectViewer" # Provides read-only access to bucket objects
  member     = "serviceAccount:${google_service_account.vm_service_account.email}"
  depends_on = [google_storage_bucket.flask_app_bucket, google_service_account.vm_service_account]
}

# Step 6: Create the VM instance
resource "google_compute_instance" "flask_docker_vm" {
  depends_on   = [google_storage_bucket_object.flask_app] # Ensure app is uploaded to GCS first
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {} # Assign a public IP
  }

  metadata = {
    startup-script = <<-EOT
      #! /bin/bash
      sudo apt-get update
      sudo apt-get install -y docker.io

      # Pull the app from GCS
      sudo gsutil cp gs://${var.gcs_bucket_name}/${var.app_archive_name} /opt/
      sudo mkdir -p /opt/app
      sudo tar -xzf /opt/${var.app_archive_name} -C /opt/app

      # Create a Dockerfile dynamically
      cat <<EOF | sudo tee /opt/app/Dockerfile
      FROM python:3.9-slim
      WORKDIR /app
      COPY . /app
      RUN pip install -r requirements.txt
      CMD ["python", "app.py"]
      EOF

      # Build and run the Docker container
      sudo docker build -t flask-app /opt/app
      sudo docker run -d --restart always -p 8080:8080 flask-app
    EOT
  }

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
