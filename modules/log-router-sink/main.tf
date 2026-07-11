locals {
  destination = (
    var.destination_type == "bigquery"
    ? "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.destination_id}"
    : "storage.googleapis.com/${var.destination_id}"
  )
}

resource "google_logging_project_sink" "this" {
  project                = var.project_id
  name                   = var.sink_name
  destination            = local.destination
  filter                 = var.filter
  unique_writer_identity = true

  dynamic "bigquery_options" {
    for_each = var.destination_type == "bigquery" ? [1] : []
    content {
      use_partitioned_tables = var.bigquery_use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name   = exclusions.value.name
      filter = exclusions.value.filter
    }
  }

  lifecycle {
    precondition {
      condition     = var.destination_type != "bigquery" || can(regex("^[a-zA-Z0-9_]+$", var.destination_id))
      error_message = "For bigquery destinations, destination_id must be a dataset id (letters, digits, underscores)."
    }
  }
}

# Grant the sink's unique writer identity write access on the destination.
resource "google_bigquery_dataset_iam_member" "writer" {
  count = var.destination_type == "bigquery" ? 1 : 0

  project    = var.project_id
  dataset_id = var.destination_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.this.writer_identity
}

resource "google_storage_bucket_iam_member" "writer" {
  count = var.destination_type == "storage" ? 1 : 0

  bucket = var.destination_id
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.this.writer_identity
}
