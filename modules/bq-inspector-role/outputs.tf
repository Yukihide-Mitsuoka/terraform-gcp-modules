output "role_id" {
  description = "Full custom role resource name (projects/.../roles/...), usable directly as an IAM binding role."
  value       = google_project_iam_custom_role.this.id
}

output "inspector_sa_email" {
  description = "Service account email the role is bound to (pass-through for wiring)."
  value       = var.inspector_sa_email
}
