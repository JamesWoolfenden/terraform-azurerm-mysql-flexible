resource "azurerm_monitor_diagnostic_setting" "examplea" {
  count                      = var.diagnostic_setting == null ? 0 : 1
  name                       = var.diagnostic_setting.name
  target_resource_id         = azurerm_mysql_flexible_server.examplea.id
  log_analytics_workspace_id = var.diagnostic_setting.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_setting.storage_account_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
