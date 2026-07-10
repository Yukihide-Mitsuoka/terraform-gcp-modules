variable "project_id" {
  description = "GCP project that owns the dataset."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset id (letters, digits, underscores)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.dataset_id))
    error_message = "Must contain only letters, digits, and underscores."
  }
}

variable "location" {
  description = "Dataset location. MUST match the policy-tag taxonomy location, or column-level security will not apply."
  type        = string
}

variable "description" {
  description = "Human-readable dataset description."
  type        = string
  default     = null
}

variable "default_table_expiration_ms" {
  description = "Default table TTL in ms; doubles as the retention-shortening lever for audit-log sink datasets. Null = no expiration."
  type        = number
  default     = null
}

variable "default_partition_expiration_ms" {
  description = "Default partition TTL in ms. Null = no expiration."
  type        = number
  default     = null
}

variable "labels" {
  description = "Labels applied to the dataset."
  type        = map(string)
  default     = {}
}

variable "iam_members" {
  description = "Dataset-level IAM bindings. Least privilege: dataset-scoped predefined roles only."
  type = list(object({
    role   = string
    member = string
  }))
  default = []

  validation {
    condition     = alltrue([for b in var.iam_members : !contains(["roles/owner", "roles/editor", "roles/viewer"], b.role)])
    error_message = "Basic roles (owner/editor/viewer) are forbidden; grant dataset-scoped predefined roles such as roles/bigquery.dataViewer."
  }

  validation {
    condition     = alltrue([for b in var.iam_members : !contains(["allUsers", "allAuthenticatedUsers"], b.member)])
    error_message = "Public members (allUsers / allAuthenticatedUsers) are forbidden on datasets."
  }
}

variable "delete_contents_on_destroy" {
  description = "Delete contained tables when the dataset is destroyed. Keep false (safe side)."
  type        = bool
  default     = false
}
