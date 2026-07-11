variable "project_id" {
  description = "GCP project that owns the data policy."
  type        = string
}

variable "location" {
  description = "Data policy location. MUST match the location of the referenced policy tag's taxonomy."
  type        = string
}

variable "data_policy_id" {
  description = "Data policy id (letters, digits, underscores)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.data_policy_id))
    error_message = "Must contain only letters, digits, and underscores."
  }
}

variable "policy_tag" {
  description = "Full policy-tag resource name the policy attaches to (bigquery-policy-tags output policy_tag_ids[level])."
  type        = string

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/taxonomies/[^/]+/policyTags/[^/]+$", var.policy_tag))
    error_message = "Must be a full policy-tag resource name: projects/.../locations/.../taxonomies/.../policyTags/..."
  }
}

variable "data_policy_type" {
  description = "Policy type. DATA_MASKING_POLICY masks tagged columns; COLUMN_LEVEL_SECURITY_POLICY only restricts access."
  type        = string
  default     = "DATA_MASKING_POLICY"

  validation {
    condition     = contains(["DATA_MASKING_POLICY", "COLUMN_LEVEL_SECURITY_POLICY"], var.data_policy_type)
    error_message = "Only DATA_MASKING_POLICY and COLUMN_LEVEL_SECURITY_POLICY are valid."
  }
}

variable "predefined_expression" {
  description = "Masking routine applied to tagged columns. Required when data_policy_type is DATA_MASKING_POLICY."
  type        = string
  default     = null

  validation {
    condition = var.predefined_expression == null || contains([
      "SHA256",
      "ALWAYS_NULL",
      "DEFAULT_MASKING_VALUE",
      "LAST_FOUR_CHARACTERS",
      "FIRST_FOUR_CHARACTERS",
      "EMAIL_MASK",
      "DATE_YEAR_MASK",
      "RANDOM_HASH",
    ], var.predefined_expression)
    error_message = "Must be one of SHA256, ALWAYS_NULL, DEFAULT_MASKING_VALUE, LAST_FOUR_CHARACTERS, FIRST_FOUR_CHARACTERS, EMAIL_MASK, DATE_YEAR_MASK, RANDOM_HASH."
  }
}

variable "masked_readers" {
  description = "Members granted roles/bigquerydatapolicy.maskedReader: they read tagged columns in masked form instead of being denied."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for m in var.masked_readers : !contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "Public members (allUsers / allAuthenticatedUsers) are forbidden."
  }
}
