resource "google_bigquery_dataset" "this" {
  project                         = var.project_id
  dataset_id                      = var.dataset_id
  location                        = var.location
  description                     = var.description
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_partition_expiration_ms
  labels                          = var.labels
  delete_contents_on_destroy      = var.delete_contents_on_destroy
}

resource "google_bigquery_dataset_iam_member" "this" {
  for_each = { for b in var.iam_members : "${b.role}/${b.member}" => b }

  project    = var.project_id
  dataset_id = google_bigquery_dataset.this.dataset_id
  role       = each.value.role
  member     = each.value.member
}
