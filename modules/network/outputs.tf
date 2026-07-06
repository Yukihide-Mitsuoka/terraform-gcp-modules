output "network_id" {
  description = "Fully-qualified VPC id."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC name."
  value       = google_compute_network.this.name
}

output "subnet_ids" {
  description = "Map: subnet name -> fully-qualified subnet id."
  value       = { for k, s in google_compute_subnetwork.this : k => s.id }
}
