variable "server" {
  description = "Core settings for the MySQL Flexible Server"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    version             = optional(string, "8.0.21")
    sku_name            = optional(string, "GP_Standard_D2ds_v4")
    zone                = optional(string, "1")
  })

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.server.name))
    error_message = "server.name must be 3-63 characters of lowercase letters, digits and hyphens, not starting or ending with a hyphen."
  }

  validation {
    condition     = can(regex("^(B|GP|MO)_", var.server.sku_name))
    error_message = "server.sku_name must be a Burstable (B_), General Purpose (GP_) or Business Critical (MO_) SKU."
  }

  validation {
    condition     = contains(["5.7", "8.0.21", "8.4"], var.server.version)
    error_message = "server.version must be 5.7, 8.0.21 or 8.4."
  }
}

variable "tags" {
  description = "Tags to apply to the server"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : length(k) <= 512 && length(v) <= 256])
    error_message = "Tag names must be at most 512 characters and tag values at most 256 characters."
  }
}

variable "public_network_access_enabled" {
  description = "Allow access from the public internet. Disable and use VNet integration (network) instead."
  type        = bool
  default     = false
}

variable "network" {
  description = "Private access (VNet integration). The subnet must be delegated to Microsoft.DBforMySQL/flexibleServers."
  type = object({
    delegated_subnet_id = optional(string)
    private_dns_zone_id = optional(string)
  })
  default = {}

  validation {
    condition     = (var.network.delegated_subnet_id == null) == (var.network.private_dns_zone_id == null)
    error_message = "network.delegated_subnet_id and network.private_dns_zone_id must be set together."
  }
}

variable "backup_retention_days" {
  description = "Backup retention in days (7-35)"
  type        = number
  default     = 35

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Store backups in the paired region"
  type        = bool
  default     = true
}

variable "identity" {
  description = "Managed identity for the server. A UserAssigned identity is required for customer managed keys."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition     = var.identity == null || try(var.identity.type, "") == "UserAssigned"
    error_message = "identity.type must be UserAssigned."
  }
}

# holden:ignore:HLD_TF_050 resource IDs of a Key Vault key and identities, not key material
variable "customer_managed_key" {
  description = "Customer managed key (CMK) encryption for data and geo-redundant backups"
  type = object({
    key_vault_key_id                     = string
    primary_user_assigned_identity_id    = string
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default = null

  validation {
    condition     = var.customer_managed_key == null || can(regex("^https://", try(var.customer_managed_key.key_vault_key_id, "")))
    error_message = "customer_managed_key.key_vault_key_id must be a versioned or versionless Key Vault key URL."
  }
}

variable "high_availability" {
  description = "High availability settings. Set to null to disable (required for Burstable SKUs)."
  type = object({
    mode                      = optional(string, "ZoneRedundant")
    standby_availability_zone = optional(string)
  })
  default = {}

  validation {
    condition     = var.high_availability == null || contains(["ZoneRedundant", "SameZone"], try(var.high_availability.mode, ""))
    error_message = "high_availability.mode must be ZoneRedundant or SameZone."
  }
}

variable "maintenance_window" {
  description = "Custom maintenance window"
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = null

  validation {
    condition = var.maintenance_window == null || (
      try(var.maintenance_window.day_of_week, 0) >= 0 && try(var.maintenance_window.day_of_week, 0) <= 6 &&
      try(var.maintenance_window.start_hour, 0) >= 0 && try(var.maintenance_window.start_hour, 0) <= 23 &&
      try(var.maintenance_window.start_minute, 0) >= 0 && try(var.maintenance_window.start_minute, 0) <= 59
    )
    error_message = "maintenance_window must have day_of_week 0-6, start_hour 0-23 and start_minute 0-59."
  }
}

variable "firewall_rules" {
  description = "Firewall rules keyed by name. Only effective when public network access is enabled."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}

  validation {
    condition = alltrue([for r in values(var.firewall_rules) :
      can(cidrhost("${r.start_ip_address}/32", 0)) && can(cidrhost("${r.end_ip_address}/32", 0)) &&
      !(r.start_ip_address == "0.0.0.0" && r.end_ip_address == "255.255.255.255")
    ])
    error_message = "Firewall rules need valid IPv4 addresses and must not open the full 0.0.0.0-255.255.255.255 range."
  }
}

variable "diagnostic_setting" {
  description = "Send server logs and metrics to Log Analytics and/or a storage account"
  type = object({
    name                       = optional(string, "diagnostics")
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
  })
  default = null

  validation {
    condition     = var.diagnostic_setting == null || try(var.diagnostic_setting.log_analytics_workspace_id, null) != null || try(var.diagnostic_setting.storage_account_id, null) != null
    error_message = "diagnostic_setting needs a log_analytics_workspace_id or storage_account_id."
  }
}

variable "storage" {
  description = "Storage settings"
  type = object({
    size_gb            = optional(number, 32)
    auto_grow_enabled  = optional(bool, true)
    io_scaling_enabled = optional(bool, false)
    iops               = optional(number)
  })
  default = {}

  validation {
    condition     = try(var.storage.size_gb, 32) >= 20 && try(var.storage.size_gb, 32) <= 16384
    error_message = "storage.size_gb must be between 20 and 16384."
  }
}

variable "administrator_login" {
  description = "Local administrator login (MySQL flexible servers always have one; disable its use with aad_auth_only)"
  type        = string
  default     = null

  validation {
    condition     = var.administrator_login == null || can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,31}$", var.administrator_login))
    error_message = "administrator_login must start with a letter and contain only letters, digits and underscores (max 32)."
  }
}

variable "administrator_password" {
  description = "Local administrator password"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.administrator_password == null || length(coalesce(var.administrator_password, "xxxxxxxx")) >= 8
    error_message = "administrator_password must be at least 8 characters."
  }
}

variable "aad_auth_only" {
  description = "Set the aad_auth_only server parameter so only Entra ID logins are accepted. Applied only when active_directory_administrator is set."
  type        = bool
  default     = true
}

variable "active_directory_administrator" {
  description = "Entra ID administrator. identity_id must be a user assigned identity attached to the server with Graph read permissions."
  type = object({
    identity_id = string
    login       = string
    object_id   = string
    tenant_id   = string
  })
  default = null

  validation {
    condition     = var.active_directory_administrator == null || can(regex("^[0-9a-fA-F-]{36}$", try(var.active_directory_administrator.tenant_id, "")))
    error_message = "active_directory_administrator.tenant_id must be a GUID."
  }
}

variable "databases" {
  description = "Databases to create, keyed by name"
  type = map(object({
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.databases) : can(regex("^[a-zA-Z0-9_]{1,64}$", k))])
    error_message = "Database names must be 1-64 letters, digits and underscores."
  }
}

variable "configurations" {
  description = "Server parameters, keyed by parameter name"
  type        = map(string)
  default = {
    "require_secure_transport" = "ON"
    "tls_version"              = "TLSv1.2,TLSv1.3"
    "audit_log_enabled"        = "ON"
    "audit_log_events"         = "CONNECTION,ADMIN,DDL,DCL"
    "local_infile"             = "OFF"
  }

  validation {
    condition     = upper(lookup(var.configurations, "require_secure_transport", "ON")) == "ON"
    error_message = "require_secure_transport must not be turned off."
  }

  validation {
    condition     = !can(regex("TLSv1(\\.[01])?(,|$)", lookup(var.configurations, "tls_version", "TLSv1.2")))
    error_message = "tls_version must not allow TLSv1 or TLSv1.1."
  }
}
