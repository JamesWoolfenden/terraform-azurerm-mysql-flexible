resource "azurerm_mysql_flexible_server_active_directory_administrator" "examplea" {
  count       = var.active_directory_administrator == null ? 0 : 1
  server_id   = azurerm_mysql_flexible_server.examplea.id
  identity_id = var.active_directory_administrator.identity_id
  login       = var.active_directory_administrator.login
  object_id   = var.active_directory_administrator.object_id
  tenant_id   = var.active_directory_administrator.tenant_id
}
