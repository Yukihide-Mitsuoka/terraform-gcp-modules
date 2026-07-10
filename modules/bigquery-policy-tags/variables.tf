variable "project_id" {
  description = "GCP project that owns the taxonomy."
  type        = string
}

variable "location" {
  description = "Taxonomy region. MUST match the location of every dataset whose columns reference these tags, or column-level security will not apply."
  type        = string
}

variable "taxonomy_display_name" {
  description = "Display name of the taxonomy (unique per project + location)."
  type        = string
}

variable "activated_policy_types" {
  description = "Policy types activated on the taxonomy."
  type        = list(string)
  default     = ["FINE_GRAINED_ACCESS_CONTROL"]

  validation {
    condition     = alltrue([for t in var.activated_policy_types : contains(["FINE_GRAINED_ACCESS_CONTROL", "POLICY_TYPE_UNSPECIFIED"], t)])
    error_message = "Only FINE_GRAINED_ACCESS_CONTROL and POLICY_TYPE_UNSPECIFIED are valid."
  }
}

variable "levels" {
  description = "Sensitivity levels, one policy tag each. Override per engagement; defaults implement the 3-tier catalog."
  type = list(object({
    name        = string
    description = string
  }))
  default = [
    { name = "high", description = "Direct identifiers and PII - masked or restricted access" },
    { name = "medium", description = "Quasi-identifiers - role-restricted read" },
    { name = "low", description = "Aggregation-safe attributes - unrestricted" },
  ]

  validation {
    condition     = length(var.levels) > 0
    error_message = "At least one level is required."
  }

  validation {
    condition     = length([for l in var.levels : l.name]) == length(distinct([for l in var.levels : l.name]))
    error_message = "Level names must be unique."
  }
}

variable "fine_grained_readers" {
  description = "Map: level name -> members granted roles/datacatalog.categoryFineGrainedReader on that level's tag."
  type        = map(list(string))
  default     = {}

  validation {
    condition     = alltrue([for members in values(var.fine_grained_readers) : alltrue([for m in members : !contains(["allUsers", "allAuthenticatedUsers"], m)])])
    error_message = "Public members (allUsers / allAuthenticatedUsers) are forbidden."
  }
}
