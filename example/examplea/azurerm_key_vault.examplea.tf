resource "azurerm_key_vault" "examplea" {
  for_each                      = local.vault_locations
  name                          = "${var.name}${each.key}"
  location                      = each.value
  resource_group_name           = azurerm_resource_group.examplea.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "premium"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  rbac_authorization_enabled    = true
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

resource "azurerm_key_vault_key" "examplea" {
  for_each        = local.vault_locations
  name            = var.name
  key_vault_id    = azurerm_key_vault.examplea[each.key].id
  key_type        = "RSA-HSM"
  key_size        = 3072
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = var.expiration_date

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P365D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_role_assignment" "examplea" {
  scope                = azurerm_key_vault.examplea["pri"].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.examplea.principal_id
}

resource "azurerm_role_assignment" "geo" {
  scope                = azurerm_key_vault.examplea["geo"].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.geo.principal_id
}

resource "azurerm_private_endpoint" "vault" {
  for_each            = local.vault_locations
  name                = "${var.name}-${each.key}-vault"
  location            = azurerm_resource_group.examplea.location
  resource_group_name = azurerm_resource_group.examplea.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${var.name}-${each.key}-vault"
    private_connection_resource_id = azurerm_key_vault.examplea[each.key].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "vault"
    private_dns_zone_ids = [azurerm_private_dns_zone.vault.id]
  }
}
