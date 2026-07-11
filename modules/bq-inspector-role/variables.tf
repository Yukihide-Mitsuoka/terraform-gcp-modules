variable "project_id" {
  description = "GCP project that owns the custom role and gets the binding."
  type        = string
}

variable "role_id" {
  description = "Custom role id (unique within the project)."
  type        = string
  default     = "bqInspector"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.]{3,64}$", var.role_id))
    error_message = "Must be 3-64 characters of letters, digits, underscores, and periods."
  }
}

variable "title" {
  description = "Human-readable role title."
  type        = string
  default     = "BigQuery Inspector (read-only)"
}

variable "description" {
  description = "Role description."
  type        = string
  default     = "Least-privilege read-only role for the BigQuery governance inspection path (FR-6). Grants no write permissions."
}

variable "permissions" {
  description = "Permissions bundled into the role. Read-only by design; the only mutating permission allowed is bigquery.jobs.create (needed to run INFORMATION_SCHEMA queries)."
  type        = list(string)
  default = [
    # BQ metadata / schema
    "bigquery.datasets.get",
    "bigquery.tables.get",
    "bigquery.tables.list",
    # INFORMATION_SCHEMA queries need a query job
    "bigquery.jobs.create",
    # Taxonomy / policy tags
    "datacatalog.taxonomies.get",
    "datacatalog.taxonomies.list",
    "datacatalog.categories.getIamPolicy",
    # Project IAM policy (read)
    "resourcemanager.projects.getIamPolicy",
    # Logging routing config (read)
    "logging.sinks.get",
    "logging.sinks.list",
    "logging.exclusions.list",
  ]

  validation {
    condition     = length(var.permissions) > 0
    error_message = "At least one permission is required."
  }

  validation {
    condition     = alltrue([for p in var.permissions : p == "bigquery.jobs.create" || !can(regex("\\.(create|update|delete|undelete|set|write)", p))])
    error_message = "Write permissions are forbidden on the inspection path (FR-6); only bigquery.jobs.create is allowed as an exception."
  }
}

variable "inspector_sa_email" {
  description = "Service account email the role is bound to (the inspector SA used by bq-inspect workflows)."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.inspector_sa_email))
    error_message = "Must be a service account email address."
  }
}
