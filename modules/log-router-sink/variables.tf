variable "project_id" {
  description = "GCP project whose logs are routed. Also assumed to own a BigQuery destination dataset."
  type        = string
}

variable "sink_name" {
  description = "Log sink name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*$", var.sink_name))
    error_message = "Must start with a letter or digit and contain only letters, digits, underscores, hyphens, and periods."
  }
}

variable "destination_type" {
  description = "Destination kind: bigquery (dataset) or storage (bucket)."
  type        = string

  validation {
    condition     = contains(["bigquery", "storage"], var.destination_type)
    error_message = "Only bigquery and storage are valid."
  }
}

variable "destination_id" {
  description = "BigQuery dataset id (in project_id) or GCS bucket name, per destination_type."
  type        = string

  validation {
    condition     = length(var.destination_id) > 0
    error_message = "Must not be empty."
  }
}

variable "filter" {
  description = "Inclusion filter, e.g. Data Access logs of high-sensitivity datasets only. Empty routes ALL logs - set one."
  type        = string
  default     = ""
}

variable "exclusions" {
  description = "Sink-scoped exclusion filters for Cloud Logging noise; matching entries are not exported by this sink."
  type = list(object({
    name   = string
    filter = string
  }))
  default = []

  validation {
    condition     = length([for e in var.exclusions : e.name]) == length(distinct([for e in var.exclusions : e.name]))
    error_message = "Exclusion names must be unique."
  }
}

variable "bigquery_use_partitioned_tables" {
  description = "Write to date-partitioned tables (BigQuery destinations only). Keep true so partition expiration can shorten retention."
  type        = bool
  default     = true
}
