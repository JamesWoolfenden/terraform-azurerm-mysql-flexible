resource "azurerm_user_assigned_identity" "examplea" {
  name                = var.name
  location            = azurerm_resource_group.examplea.location
  resource_group_name = azurerm_resource_group.examplea.name
}

resource "azurerm_user_assigned_identity" "geo" {
  name                = "${var.name}-geo"
  location            = var.geo_location
  resource_group_name = azurerm_resource_group.examplea.name
}
