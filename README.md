# terraform-azurerm-mysql-flexible

[![Build Status](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-azurerm-mysql-flexible.svg)](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-azurerm-mysql-flexible.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for an Azure Database for MySQL Flexible Server with secure defaults: no public network access, VNet integration, customer managed key encryption, zone-redundant high availability, geo-redundant backups, TLS 1.2+ enforced, audit logging, local_infile off and Entra ID only authentication (aad_auth_only) once an Entra administrator is set. Supersedes the single-server **terraform-azurerm-mysql** module.

---

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

## Usage

Include this repository as a module in your existing Terraform code:

```hcl
module "mysql" {
  source  = "JamesWoolfenden/mysql-flexible/azurerm"
  version = "0.0.1"

  server = {
    name                = "mymysqlserver"
    resource_group_name = "my-rg"
    location            = "uksouth"
  }

  network = {
    delegated_subnet_id = azurerm_subnet.mysql.id
    private_dns_zone_id = azurerm_private_dns_zone.mysql.id
  }

  administrator_login    = "mysqladmin"
  administrator_password = random_password.mysql.result

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mysql.id]
  }

  customer_managed_key = {
    key_vault_key_id                  = azurerm_key_vault_key.mysql.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.mysql.id
  }

  active_directory_administrator = {
    identity_id = azurerm_user_assigned_identity.mysql.id
    login       = "mysql-admins"
    object_id   = "00000000-0000-0000-0000-000000000000"
    tenant_id   = data.azurerm_client_config.current.tenant_id
  }
}
```

The example in the **examplea** folder creates the supporting resources (resource group, network, Key Vault, identities, Log Analytics) needed to deploy the module securely.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_monitor_diagnostic_setting.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mysql_flexible_database.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database) | resource |
| [azurerm_mysql_flexible_server.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |
| [azurerm_mysql_flexible_server_active_directory_administrator.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_active_directory_administrator) | resource |
| [azurerm_mysql_flexible_server_configuration.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_configuration) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.examplea](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aad_auth_only"></a> [aad\_auth\_only](#input\_aad\_auth\_only) | Set the aad\_auth\_only server parameter so only Entra ID logins are accepted. Applied only when active\_directory\_administrator is set. | `bool` | `true` | no |
| <a name="input_active_directory_administrator"></a> [active\_directory\_administrator](#input\_active\_directory\_administrator) | Entra ID administrator. identity\_id must be a user assigned identity attached to the server with Graph read permissions. | <pre>object({<br/>    identity_id = string<br/>    login       = string<br/>    object_id   = string<br/>    tenant_id   = string<br/>  })</pre> | `null` | no |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Local administrator login (MySQL flexible servers always have one; disable its use with aad\_auth\_only) | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | Local administrator password | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention in days (7-35) | `number` | `35` | no |
| <a name="input_configurations"></a> [configurations](#input\_configurations) | Server parameters, keyed by parameter name | `map(string)` | <pre>{<br/>  "audit_log_enabled": "ON",<br/>  "audit_log_events": "CONNECTION,ADMIN,DDL,DCL",<br/>  "local_infile": "OFF",<br/>  "require_secure_transport": "ON",<br/>  "tls_version": "TLSv1.2,TLSv1.3"<br/>}</pre> | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key (CMK) encryption for data and geo-redundant backups | <pre>object({<br/>    key_vault_key_id                     = string<br/>    primary_user_assigned_identity_id    = string<br/>    geo_backup_key_vault_key_id          = optional(string)<br/>    geo_backup_user_assigned_identity_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Databases to create, keyed by name | <pre>map(object({<br/>    charset   = optional(string, "utf8mb4")<br/>    collation = optional(string, "utf8mb4_unicode_ci")<br/>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_setting"></a> [diagnostic\_setting](#input\_diagnostic\_setting) | Send server logs and metrics to Log Analytics and/or a storage account | <pre>object({<br/>    name                       = optional(string, "diagnostics")<br/>    log_analytics_workspace_id = optional(string)<br/>    storage_account_id         = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules keyed by name. Only effective when public network access is enabled. | <pre>map(object({<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Store backups in the paired region | `bool` | `true` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | High availability settings. Set to null to disable (required for Burstable SKUs). | <pre>object({<br/>    mode                      = optional(string, "ZoneRedundant")<br/>    standby_availability_zone = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity for the server. A UserAssigned identity is required for customer managed keys. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Custom maintenance window | <pre>object({<br/>    day_of_week  = optional(number, 0)<br/>    start_hour   = optional(number, 0)<br/>    start_minute = optional(number, 0)<br/>  })</pre> | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Private access (VNet integration). The subnet must be delegated to Microsoft.DBforMySQL/flexibleServers. | <pre>object({<br/>    delegated_subnet_id = optional(string)<br/>    private_dns_zone_id = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow access from the public internet. Disable and use VNet integration (network) instead. | `bool` | `false` | no |
| <a name="input_server"></a> [server](#input\_server) | Core settings for the MySQL Flexible Server | <pre>object({<br/>    name                = string<br/>    resource_group_name = string<br/>    location            = string<br/>    version             = optional(string, "8.0.21")<br/>    sku_name            = optional(string, "GP_Standard_D2ds_v4")<br/>    zone                = optional(string, "1")<br/>  })</pre> | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Storage settings | <pre>object({<br/>    size_gb            = optional(number, 32)<br/>    auto_grow_enabled  = optional(bool, true)<br/>    io_scaling_enabled = optional(bool, false)<br/>    iops               = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the server | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_active_directory_administrator"></a> [active\_directory\_administrator](#output\_active\_directory\_administrator) | The MySQL Flexible Server Entra ID administrator |
| <a name="output_configurations"></a> [configurations](#output\_configurations) | The MySQL Flexible Server configurations |
| <a name="output_databases"></a> [databases](#output\_databases) | The MySQL Flexible Server databases |
| <a name="output_diagnostic_setting"></a> [diagnostic\_setting](#output\_diagnostic\_setting) | The diagnostic setting for the server |
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | The MySQL Flexible Server firewall rules |
| <a name="output_server"></a> [server](#output\_server) | The MySQL Flexible Server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Policy

This is the policy required to build this project:

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang

# apply role — full permissions for terraform apply
# Bind this role to the applier SA on protected branches only.
resource "azurerm_role_definition" "terraform_pike" {
  role_definition_id = local.apply_uuid
  name               = "terraform_pike"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.DBforMySQL/flexibleServers/administrators/delete",
    "Microsoft.DBforMySQL/flexibleServers/administrators/read",
    "Microsoft.DBforMySQL/flexibleServers/administrators/write",
    "Microsoft.DBforMySQL/flexibleServers/configurations/read",
    "Microsoft.DBforMySQL/flexibleServers/configurations/write",
    "Microsoft.DBforMySQL/flexibleServers/databases/delete",
    "Microsoft.DBforMySQL/flexibleServers/databases/read",
    "Microsoft.DBforMySQL/flexibleServers/databases/write",
    "Microsoft.DBforMySQL/flexibleServers/delete",
    "Microsoft.DBforMySQL/flexibleServers/firewallRules/delete",
    "Microsoft.DBforMySQL/flexibleServers/firewallRules/read",
    "Microsoft.DBforMySQL/flexibleServers/firewallRules/write",
    "Microsoft.DBforMySQL/flexibleServers/read",
    "Microsoft.DBforMySQL/flexibleServers/write",
    "Microsoft.Insights/DiagnosticSettings/Delete",
    "Microsoft.Insights/DiagnosticSettings/Read",
    "Microsoft.Insights/DiagnosticSettings/Write",
    "Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.primary.id]
}

# plan role — read-only permissions for terraform plan
# Bind this role to the planner SA on all branches.
resource "azurerm_role_definition" "terraform_pike_plan" {
  role_definition_id = local.plan_uuid
  name               = "terraform_pike_plan"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.DBforMySQL/flexibleServers/administrators/read",
    "Microsoft.DBforMySQL/flexibleServers/configurations/read",
    "Microsoft.DBforMySQL/flexibleServers/databases/read",
    "Microsoft.DBforMySQL/flexibleServers/firewallRules/read",
    "Microsoft.DBforMySQL/flexibleServers/read",
    "Microsoft.Insights/DiagnosticSettings/Read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.primary.id]
}

locals {
  apply_uuid = uuid()
  plan_uuid  = uuid()
}

data "azurerm_subscription" "primary" {}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-azurerm-acr](https://github.com/jameswoolfenden/terraform-azurerm-acr) - Azure Container Registry

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/JamesWoolfenden/terraform-azurerm-mysql-flexible/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
