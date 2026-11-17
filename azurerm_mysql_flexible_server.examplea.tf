# holden:ignore:HLD_TF_063_MEDIUM one dynamic block per optional nested block (identity, CMK, HA, maintenance) is inherent to exposing them as inputs
# holden:ignore:HLD_AZ_200 private access is via VNet integration (delegated_subnet_id + private DNS); a VNet-integrated flexible server cannot also take a private endpoint
resource "azurerm_mysql_flexible_server" "examplea" {
  name                = var.server.name
  resource_group_name = var.server.resource_group_name
  location            = var.server.location
  version             = var.server.version
  sku_name            = var.server.sku_name
  zone                = var.server.zone

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  public_network_access = local.public_network_access
  delegated_subnet_id   = var.network.delegated_subnet_id
  private_dns_zone_id   = var.network.private_dns_zone_id

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  storage {
    size_gb            = var.storage.size_gb
    auto_grow_enabled  = var.storage.auto_grow_enabled
    io_scaling_enabled = var.storage.io_scaling_enabled
    iops               = var.storage.iops
  }

  dynamic "identity" {
    for_each = local.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.customer_managed_key
    content {
      key_vault_key_id                     = customer_managed_key.value.key_vault_key_id
      primary_user_assigned_identity_id    = customer_managed_key.value.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = customer_managed_key.value.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = customer_managed_key.value.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "high_availability" {
    for_each = local.high_availability
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = local.maintenance_window
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}
