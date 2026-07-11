output "sink_id" {
  description = "Sink resource id."
  value       = google_logging_project_sink.this.id
}

output "writer_identity" {
  description = "Service account the sink writes as (already granted write access on the destination by this module)."
  value       = google_logging_project_sink.this.writer_identity
}
