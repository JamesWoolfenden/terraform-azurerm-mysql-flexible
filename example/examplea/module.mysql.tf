# holden:ignore:HLD_TF_026 the example intentionally calls the module under test via ../../ so it always exercises the working tree
# holden:ignore:HLD_TF_078 six cohesive resource types for one database server (server, databases, firewall, parameters, Entra admin, diagnostics)
module "mysql" {
  source = "../../"

  server = {
    name                = var.name
    resource_group_name = azurerm_resource_group.examplea.name
    location            = azurerm_resource_group.examplea.location
  }

  network = {
    delegated_subnet_id = azurerm_subnet.examplea.id
    private_dns_zone_id = azurerm_private_dns_zone.examplea.id
  }

  administrator_login    = "mysqladmin"
  administrator_password = random_password.examplea.result

  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.examplea.id,
      azurerm_user_assigned_identity.geo.id,
    ]
  }

  customer_managed_key = {
    key_vault_key_id                     = azurerm_key_vault_key.examplea["pri"].id
    primary_user_assigned_identity_id    = azurerm_user_assigned_identity.examplea.id
    geo_backup_key_vault_key_id          = azurerm_key_vault_key.examplea["geo"].id
    geo_backup_user_assigned_identity_id = azurerm_user_assigned_identity.geo.id
  }

  active_directory_administrator = {
    identity_id = azurerm_user_assigned_identity.examplea.id
    login       = var.active_directory_administrator.login
    object_id   = var.active_directory_administrator.object_id
    tenant_id   = data.azurerm_client_config.current.tenant_id
  }

  databases = var.databases

  diagnostic_setting = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.examplea.id
  }

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.examplea,
    azurerm_role_assignment.examplea,
    azurerm_role_assignment.geo,
  ]
}
