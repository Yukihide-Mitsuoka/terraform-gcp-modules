resource "google_project_iam_custom_role" "this" {
  project     = var.project_id
  role_id     = var.role_id
  title       = var.title
  description = var.description
  permissions = var.permissions
}

resource "google_project_iam_member" "inspector" {
  project = var.project_id
  role    = google_project_iam_custom_role.this.id
  member  = "serviceAccount:${var.inspector_sa_email}"
}
