variable "project_id" {
  description = "GCP project ID"
}

variable "region" {
  description = "GCP region"
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  default     = "us-central1-a"
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket to store the app archive"
  default     = "app-deployment-bucket-1093"
}

variable "app_directory" {
  description = "Local path to the Flask application directory"
  default     = "./app"
}

variable "app_archive_name" {
  description = "The name of the tar archive for the Flask app"
  default     = "flask-app.tar.gz"
}

variable "vm_name" {
  description = "The name of the virtual machine instance"
  default     = "flask-docker-vm"
}

variable "vm_machine_type" {
  description = "The machine type for the virtual machine"
  default     = "e2-micro"
}