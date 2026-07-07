output "workload_identity_provider" {
  description = "Full provider resource name — value for google-github-actions/auth workload_identity_provider."
  value       = google_iam_workload_identity_pool_provider.this.name
}

output "service_account_email" {
  description = "Deployer service account email — value for google-github-actions/auth service_account."
  value       = google_service_account.this.email
}

output "pool_name" {
  description = "Full workload identity pool resource name."
  value       = google_iam_workload_identity_pool.this.name
}
