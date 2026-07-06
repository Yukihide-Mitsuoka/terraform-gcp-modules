variable "project_id" {
  description = "GCP project that owns the network."
  type        = string
}

variable "name" {
  description = "VPC name; also prefixes subnet names (<name>-<subnet>)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "Must be a valid GCP resource name (lowercase, digits, hyphens)."
  }
}

variable "subnets" {
  description = "Subnets to create in the VPC."
  type = list(object({
    name   = string
    cidr   = string
    region = string
  }))
  default = []

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrhost(s.cidr, 0))])
    error_message = "Every subnet cidr must be a valid CIDR block."
  }
}
