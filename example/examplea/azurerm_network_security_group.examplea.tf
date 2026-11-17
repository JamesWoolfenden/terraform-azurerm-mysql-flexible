resource "azurerm_network_security_group" "examplea" {
  name                = var.name
  location            = azurerm_resource_group.examplea.location
  resource_group_name = azurerm_resource_group.examplea.name

  security_rule {
    name                       = "allow-vnet-mysql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "examplea" {
  subnet_id                 = azurerm_subnet.examplea.id
  network_security_group_id = azurerm_network_security_group.examplea.id
}

resource "azurerm_subnet_network_security_group_association" "endpoints" {
  subnet_id                 = azurerm_subnet.endpoints.id
  network_security_group_id = azurerm_network_security_group.examplea.id
}
