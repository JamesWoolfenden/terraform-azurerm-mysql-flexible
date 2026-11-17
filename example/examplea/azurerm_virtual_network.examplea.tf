resource "azurerm_virtual_network" "examplea" {
  name                = var.name
  location            = azurerm_resource_group.examplea.location
  resource_group_name = azurerm_resource_group.examplea.name
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "examplea" {
  name                            = "mysql"
  resource_group_name             = azurerm_resource_group.examplea.name
  virtual_network_name            = azurerm_virtual_network.examplea.name
  address_prefixes                = ["10.30.1.0/24"]
  default_outbound_access_enabled = false

  delegation {
    name = "mysql"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "endpoints" {
  name                              = "endpoints"
  resource_group_name               = azurerm_resource_group.examplea.name
  virtual_network_name              = azurerm_virtual_network.examplea.name
  address_prefixes                  = ["10.30.2.0/24"]
  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Enabled"
}
