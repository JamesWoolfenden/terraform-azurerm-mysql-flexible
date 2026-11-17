resource "azurerm_mysql_flexible_server_configuration" "examplea" {
  for_each            = local.configurations
  name                = each.key
  resource_group_name = azurerm_mysql_flexible_server.examplea.resource_group_name
  server_name         = azurerm_mysql_flexible_server.examplea.name
  value               = each.value

  depends_on = [azurerm_mysql_flexible_server_active_directory_administrator.examplea]
}
