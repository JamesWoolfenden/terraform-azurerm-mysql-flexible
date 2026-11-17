resource "azurerm_mysql_flexible_server_firewall_rule" "examplea" {
  for_each            = var.firewall_rules
  name                = each.key
  resource_group_name = azurerm_mysql_flexible_server.examplea.resource_group_name
  server_name         = azurerm_mysql_flexible_server.examplea.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}
