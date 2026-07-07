variable "project_id" {
  description = "GCP project that hosts the identity pool and service account."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to authenticate, as owner/name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "Must be owner/name (e.g. my-org/my-app)."
  }
}

variable "pool_id" {
  description = "Workload Identity Pool id."
  type        = string
  default     = "github"
}

variable "provider_id" {
  description = "Workload Identity Pool Provider id."
  type        = string
  default     = "github-oidc"
}

variable "service_account_id" {
  description = "Account id of the deployer service account (name before @)."
  type        = string
  default     = "github-deployer"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "Must be a valid service account id (6-30 chars, lowercase)."
  }
}

variable "roles" {
  description = "Project-level IAM roles granted to the deployer (least privilege: only what the pipeline uses, e.g. roles/run.admin, roles/artifactregistry.writer)."
  type        = list(string)
  default     = []
}

variable "attribute_condition" {
  description = "Override the provider attribute condition (default restricts to github_repository). Use to tighten further, e.g. branch-only deploys."
  type        = string
  default     = null
}
