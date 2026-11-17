resource "azurerm_private_dns_zone" "examplea" {
  name                = "${var.name}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.examplea.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "examplea" {
  name                  = var.name
  private_dns_zone_name = azurerm_private_dns_zone.examplea.name
  resource_group_name   = azurerm_resource_group.examplea.name
  virtual_network_id    = azurerm_virtual_network.examplea.id
}

resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.examplea.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault" {
  name                  = "${var.name}-vault"
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  resource_group_name   = azurerm_resource_group.examplea.name
  virtual_network_id    = azurerm_virtual_network.examplea.id
}
