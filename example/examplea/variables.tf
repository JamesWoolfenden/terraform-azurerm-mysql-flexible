variable "name" {
  description = "Name used for all example resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,19}$", var.name))
    error_message = "name must be 3-20 lowercase letters and digits, starting with a letter (Key Vault names get a suffix)."
  }
}

variable "location" {
  description = "Azure region for the server"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "location must be an Azure region name such as uksouth."
  }
}

variable "geo_location" {
  description = "Paired Azure region holding the geo-backup CMK"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.geo_location))
    error_message = "geo_location must be an Azure region name such as ukwest."
  }
}

variable "expiration_date" {
  description = "Expiry date for the CMKs (RFC3339)"
  type        = string

  validation {
    condition     = can(formatdate("YYYY", var.expiration_date))
    error_message = "expiration_date must be an RFC3339 timestamp."
  }
}

variable "active_directory_administrator" {
  description = "Entra ID group or user to make the server administrator"
  type = object({
    login     = string
    object_id = string
  })

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.active_directory_administrator.object_id))
    error_message = "active_directory_administrator.object_id must be a GUID."
  }
}

variable "databases" {
  description = "Databases to create"
  type = map(object({
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = {}

  validation {
    condition     = length(var.databases) <= 50
    error_message = "databases is limited to 50 entries in this example."
  }
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : length(k) <= 512 && length(v) <= 256])
    error_message = "Tag names must be at most 512 characters and tag values at most 256 characters."
  }
}
