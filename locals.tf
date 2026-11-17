locals {
  public_network_access = var.public_network_access_enabled ? "Enabled" : "Disabled"

  identity             = var.identity == null ? [] : [var.identity]
  customer_managed_key = var.customer_managed_key == null ? [] : [var.customer_managed_key]
  high_availability    = var.high_availability == null ? [] : [var.high_availability]
  maintenance_window   = var.maintenance_window == null ? [] : [var.maintenance_window]

  # aad_auth_only locks out local logins, so it is only applied once an Entra administrator exists
  aad_auth_only  = var.aad_auth_only && var.active_directory_administrator != null ? { "aad_auth_only" = "ON" } : {}
  configurations = merge(var.configurations, local.aad_auth_only)
}
