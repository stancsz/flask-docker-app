output "vm_public_ip" {
  description = "The public IP of the VM running the Flask app"
  value       = google_compute_instance.flask_docker_vm.network_interface[0].access_config[0].nat_ip
}