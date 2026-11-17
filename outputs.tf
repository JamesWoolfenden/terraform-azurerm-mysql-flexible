output "server" {
  description = "The MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.examplea
  sensitive   = true
}

output "databases" {
  description = "The MySQL Flexible Server databases"
  value       = azurerm_mysql_flexible_database.examplea
}

output "firewall_rules" {
  description = "The MySQL Flexible Server firewall rules"
  value       = azurerm_mysql_flexible_server_firewall_rule.examplea
}

output "configurations" {
  description = "The MySQL Flexible Server configurations"
  value       = azurerm_mysql_flexible_server_configuration.examplea
}

output "active_directory_administrator" {
  description = "The MySQL Flexible Server Entra ID administrator"
  value       = azurerm_mysql_flexible_server_active_directory_administrator.examplea
}

output "diagnostic_setting" {
  description = "The diagnostic setting for the server"
  value       = azurerm_monitor_diagnostic_setting.examplea
}
