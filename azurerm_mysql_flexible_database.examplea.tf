resource "azurerm_mysql_flexible_database" "examplea" {
  for_each            = var.databases
  name                = each.key
  resource_group_name = azurerm_mysql_flexible_server.examplea.resource_group_name
  server_name         = azurerm_mysql_flexible_server.examplea.name
  charset             = each.value.charset
  collation           = each.value.collation
}
