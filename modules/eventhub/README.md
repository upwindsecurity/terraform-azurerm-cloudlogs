# Microsoft Azure Monitor Logs Module

This Terraform module creates the necessary Azure infrastructure to enable Azure Monitor Logs monitoring with the
Upwind platform using Azure Event Hubs. The module supports both creating new Event Hub infrastructure and integrating
with existing Event Hub setups.

## Usage

### Basic Usage

```hcl
module "upwind_azure_cloudlogs" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/eventhub"

  # Azure configuration
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Stream from specific subscriptions
  stream_subscription_ids = [
    "12345678-1234-1234-1234-123456789012",
    "12345678-1234-1234-1234-123456789013",
  ]

  # Service principal configuration
  onboarding_service_principal_client_id = "12345678-1234-1234-1234-5678"

  # Enable Entra ID logs
  diagnostic_setting_enable_entra_logs = true
}
```

### Advanced Usage with Management Groups

```hcl
module "upwind_azure_cloudlogs" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/eventhub"

  # Azure configuration
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Stream from management groups with exclusions
  stream_management_group_ids = [
    "mg-production",
    "mg-development",
  ]
  stream_exclude_subscription_ids = [
    "12345678-1234-1234-1234-sandbox123",
  ]

  # Service principal configuration
  onboarding_service_principal_client_id = "12345678-1234-1234-1234-5678"

  # Enable Entra ID logs
  diagnostic_setting_enable_entra_logs = true
}
```

### Using Existing Event Hub

```hcl
module "upwind_azure_cloudlogs" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/eventhub"

  # Azure configuration
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Use existing Event Hub
  use_existing_eventhub   = true
  resource_group_name     = "existing-eventhub-rg"
  eventhub_name           = "existing-eventhub"
  eventhub_namespace_name = "existing-eventhub-namespace"

  # Stream configuration
  stream_subscription_ids = ["12345678-1234-1234-1234-123456789012"]

  # Service principal configuration
  onboarding_service_principal_client_id = "12345678-1234-1234-1234-5678"
}
```

## Streaming Scope Options

The module supports flexible streaming scope configuration with the following priority order:

1. **Specific Subscriptions**: `stream_subscription_ids` - Stream from only specified subscriptions
2. **Management Groups**: `stream_management_group_ids` - Stream from all subscriptions under management groups
3. **All Subscriptions with Exclusions**: `stream_exclude_subscription_ids` - Stream from all subscriptions except
   specified ones
4. **All Subscriptions**: `stream_all_subscriptions = true` - Stream from all subscriptions in tenant
5. **Default**: Stream from infrastructure subscription only

## Examples

See the [examples](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/) directory for
complete working examples:

- **[eventhub-basic](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-basic/)**:
  Simple subscription-based monitoring
- **[eventhub-management-groups](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-management-groups/)**:
  Enterprise organizational monitoring
- **[eventhub-existing](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-existing/)**:
  Integration with existing Event Hub infrastructure
- **[eventhub-tenant-wide](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-tenant-wide/)**:
  Tenant-wide monitoring with exclusions

## Prerequisites

- Azure subscription with appropriate permissions
- Azure AD tenant access
- Terraform >= 1.9
- Azure CLI or service principal authentication

## Permissions Required

The executing principal needs the following permissions:

- **Subscription level**: Contributor or custom role with Event Hub, Key Vault, and diagnostic settings permissions
- **Azure AD level**: Application Administrator or custom role for service principal creation
- **Management Group level** (if using management groups): Reader access to management groups

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.7.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.56.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_auto_discovery"></a> [auto\_discovery](#module\_auto\_discovery) | ../auto-discovery | n/a |

## Resources

| Name | Type |
|------|------|
| [azuread_application.integration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.integration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_eventhub.new](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.new](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.new](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_key_vault.integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.sp_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.sp_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_aad_diagnostic_setting.integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.new](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.eh_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.monitoring_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.onboarding_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current_sp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_eventhub.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub) | data source |
| [azurerm_eventhub_namespace.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace) | data source |
| [azurerm_management_group.streaming](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_resource_group.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_subscriptions.all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscriptions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name_prefix"></a> [application\_name\_prefix](#input\_application\_name\_prefix) | The Upwind AD application display name prefix. | `string` | `"upwindsecurity-cloudlogs"` | no |
| <a name="input_application_owners"></a> [application\_owners](#input\_application\_owners) | List of user IDs that will be set as owners of the Azure application &<br/>service principal. Each ID should be in the form of a GUID. If this list<br/>is left empty, the owner defaults to the authenticated principal. | `list(string)` | `[]` | no |
| <a name="input_application_password_expiration_date"></a> [application\_password\_expiration\_date](#input\_application\_password\_expiration\_date) | The expiration date for the Azure AD application password in RFC3339 format<br/>(e.g., `2999-12-31T23:59:59Z`). This determines when the application<br/>password expires. | `string` | `"2999-12-31T23:59:59Z"` | no |
| <a name="input_diagnostic_setting_activity_log_categories"></a> [diagnostic\_setting\_activity\_log\_categories](#input\_diagnostic\_setting\_activity\_log\_categories) | List of activity log categories to enable in the diagnostic setting.<br/>Currently, only `Administrative` and `Security` categories are<br/>supported by Upwind. Do not modify unless instructed by Upwind support. | `list(string)` | <pre>[<br/>  "Administrative",<br/>  "Security"<br/>]</pre> | no |
| <a name="input_diagnostic_setting_enable_entra_logs"></a> [diagnostic\_setting\_enable\_entra\_logs](#input\_diagnostic\_setting\_enable\_entra\_logs) | Whether to enable or disable Entra logs. | `bool` | `true` | no |
| <a name="input_diagnostic_setting_entra_log_categories"></a> [diagnostic\_setting\_entra\_log\_categories](#input\_diagnostic\_setting\_entra\_log\_categories) | List of Entra ID log categories to enable in the diagnostic setting.<br/>Currently, only `AuditLogs` and `SignInLogs` categories are<br/>supported by Upwind. Do not modify unless instructed by Upwind support. | `list(string)` | <pre>[<br/>  "AuditLogs",<br/>  "SignInLogs"<br/>]</pre> | no |
| <a name="input_diagnostic_setting_entra_name"></a> [diagnostic\_setting\_entra\_name](#input\_diagnostic\_setting\_entra\_name) | The name of the Entra diagnostic setting to be created. | `string` | `"upwindsecurity-entra"` | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | The name of the diagnostic setting to be created. | `string` | `"upwindsecurity"` | no |
| <a name="input_enable_auto_discovery"></a> [enable\_auto\_discovery](#input\_enable\_auto\_discovery) | Whether to enable auto-discovery of diagnostic settings. | `bool` | `false` | no |
| <a name="input_eventhub_authorization_rule_name"></a> [eventhub\_authorization\_rule\_name](#input\_eventhub\_authorization\_rule\_name) | The name of the authorization rule to be created. | `string` | `"upwindsecurity"` | no |
| <a name="input_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#input\_eventhub\_consumer\_group\_name) | The name of the consumer group to be created. | `string` | `"upwindsecurity"` | no |
| <a name="input_eventhub_enable_auto_inflate"></a> [eventhub\_enable\_auto\_inflate](#input\_eventhub\_enable\_auto\_inflate) | Whether to enable Event Hub namespace auto-inflate. | `bool` | `true` | no |
| <a name="input_eventhub_max_throughput_units"></a> [eventhub\_max\_throughput\_units](#input\_eventhub\_max\_throughput\_units) | The maximum number of throughput units when auto-inflate is enabled. | `number` | `20` | no |
| <a name="input_eventhub_message_retention_days"></a> [eventhub\_message\_retention\_days](#input\_eventhub\_message\_retention\_days) | The retention period for messages in the Event Hub, in days. | `number` | `1` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name of the Event Hub to be created or the existing one. | `string` | `"upwindsecurity"` | no |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | The name of the Event Hub namespace to be created or the existing one. | `string` | `"upwindsecurity"` | no |
| <a name="input_eventhub_partition_count"></a> [eventhub\_partition\_count](#input\_eventhub\_partition\_count) | The number of partitions of the Event Hub. | `number` | `4` | no |
| <a name="input_eventhub_pricing_tier"></a> [eventhub\_pricing\_tier](#input\_eventhub\_pricing\_tier) | The pricing tier of the Event Hub Namespace. | `string` | `"Standard"` | no |
| <a name="input_infrastructure_subscription_id"></a> [infrastructure\_subscription\_id](#input\_infrastructure\_subscription\_id) | The subscription ID where the infrastructure resources (Event Hub, Key<br/>Vault, Service Principal, etc.) will be deployed or already exist. This<br/>must match the subscription context of your authenticated Azure provider. | `string` | n/a | yes |
| <a name="input_key_vault_client_id_secret_name"></a> [key\_vault\_client\_id\_secret\_name](#input\_key\_vault\_client\_id\_secret\_name) | The name of the Key Vault secret for service principal client ID. | `string` | `"sp-client-id"` | no |
| <a name="input_key_vault_client_secret_secret_name"></a> [key\_vault\_client\_secret\_secret\_name](#input\_key\_vault\_client\_secret\_secret\_name) | The name of the Key Vault secret for service principal client secret. | `string` | `"sp-client-secret"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the Key Vault used to store integration service principal<br/>secrets and credentials. | `string` | `"upwindsecurity"` | no |
| <a name="input_key_vault_network_acls_bypass"></a> [key\_vault\_network\_acls\_bypass](#input\_key\_vault\_network\_acls\_bypass) | Specifies which traffic can bypass the network rules. Possible values are<br/>`AzureServices` and `None`. Only used when `key_vault_network_acls_enabled` is `true`. | `string` | `"AzureServices"` | no |
| <a name="input_key_vault_network_acls_default_action"></a> [key\_vault\_network\_acls\_default\_action](#input\_key\_vault\_network\_acls\_default\_action) | The default action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`.<br/>Possible values are `Allow` and `Deny`. Only used when `key_vault_network_acls_enabled` is `true`. | `string` | `"Deny"` | no |
| <a name="input_key_vault_network_acls_enabled"></a> [key\_vault\_network\_acls\_enabled](#input\_key\_vault\_network\_acls\_enabled) | Whether to enable network ACLs for the Key Vault. When enabled, network<br/>access rules will be applied based on the other network ACL variables. | `bool` | `false` | no |
| <a name="input_key_vault_network_acls_ip_rules"></a> [key\_vault\_network\_acls\_ip\_rules](#input\_key\_vault\_network\_acls\_ip\_rules) | One or more IP addresses or CIDR blocks which should be able to access<br/>the Key Vault. Only used when `key_vault_network_acls_enabled` is `true`. | `list(string)` | `[]` | no |
| <a name="input_key_vault_network_acls_virtual_network_subnet_ids"></a> [key\_vault\_network\_acls\_virtual\_network\_subnet\_ids](#input\_key\_vault\_network\_acls\_virtual\_network\_subnet\_ids) | One or more subnet IDs which should be able to access this Key Vault.<br/>Only used when `key_vault_network_acls_enabled` is `true`. | `list(string)` | `[]` | no |
| <a name="input_key_vault_purge_protection_enabled"></a> [key\_vault\_purge\_protection\_enabled](#input\_key\_vault\_purge\_protection\_enabled) | Whether to enable purge protection for the Key Vault. | `bool` | `true` | no |
| <a name="input_key_vault_rbac_authorization_enabled"></a> [key\_vault\_rbac\_authorization\_enabled](#input\_key\_vault\_rbac\_authorization\_enabled) | Whether to enable RBAC authorization for the Key Vault. | `bool` | `true` | no |
| <a name="input_key_vault_secret_expiration_date"></a> [key\_vault\_secret\_expiration\_date](#input\_key\_vault\_secret\_expiration\_date) | The expiration date for the Key Vault secrets in RFC3339 format<br/>(e.g., `2025-12-31T23:59:59Z`). If not specified, secrets will not expire. | `string` | `null` | no |
| <a name="input_key_vault_sku_name"></a> [key\_vault\_sku\_name](#input\_key\_vault\_sku\_name) | The SKU name of the Key Vault. | `string` | `"standard"` | no |
| <a name="input_onboarding_service_principal_client_id"></a> [onboarding\_service\_principal\_client\_id](#input\_onboarding\_service\_principal\_client\_id) | The client ID of the Upwind onboarding service principal. This service<br/>principal will be granted Key Vault Secrets Officer access to manage<br/>the integration service principal secrets. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where the integration resources will be created or the existing<br/>Event Hub. | `string` | `"eastus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the existing resource group for the Event Hub. | `string` | `"upwindsecurity"` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | The suffix to append to all resources created by this module. | `string` | `""` | no |
| <a name="input_stream_all_subscriptions"></a> [stream\_all\_subscriptions](#input\_stream\_all\_subscriptions) | When set to true, create diagnostic settings to stream logs from ALL<br/>subscriptions within the tenant to the Event Hub. Overrides<br/>`stream_subscription_ids` and `stream_management_group_ids`. | `bool` | `false` | no |
| <a name="input_stream_exclude_subscription_ids"></a> [stream\_exclude\_subscription\_ids](#input\_stream\_exclude\_subscription\_ids) | List of subscription IDs to exclude from log streaming. When specified,<br/>diagnostic settings will be created for all subscriptions in the tenant<br/>except the ones listed here. This variable is mutually exclusive with<br/>`stream_subscription_ids`. | `list(string)` | `[]` | no |
| <a name="input_stream_management_group_ids"></a> [stream\_management\_group\_ids](#input\_stream\_management\_group\_ids) | List of management group IDs to include all subscriptions from for log<br/>streaming. All subscriptions under these management groups (including<br/>nested management groups) will have diagnostic settings created to stream<br/>logs to the Event Hub. Can be combined with `stream_exclude_subscription_ids`<br/>to exclude specific subscriptions. Mutually exclusive with `stream_subscription_ids`. | `list(string)` | `[]` | no |
| <a name="input_stream_subscription_ids"></a> [stream\_subscription\_ids](#input\_stream\_subscription\_ids) | List of subscription IDs to create diagnostic settings for, streaming<br/>their logs to the Event Hub. If `stream_all_subscriptions` is false and<br/>this list is empty, only the current subscription will have its logs<br/>streamed. This variable is mutually exclusive with<br/>`stream_exclude_subscription_ids`. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure Tenant that will be onboarded to the Upwind Azure Monitor Logs monitoring. | `string` | n/a | yes |
| <a name="input_use_existing_eventhub"></a> [use\_existing\_eventhub](#input\_use\_existing\_eventhub) | Whether to use an existing Event Hub. If false, create a new one. | `bool` | `false` | no |
| <a name="input_use_existing_resource_group"></a> [use\_existing\_resource\_group](#input\_use\_existing\_resource\_group) | Whether to use an existing resource group. If false, create a new one. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Azure AD application. |
| <a name="output_application_name"></a> [application\_name](#output\_application\_name) | The display name of the Azure AD application. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | The name of the consumer group created for processing logs. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | The name of the Event Hub used for Azure Monitor Logs monitoring. |
| <a name="output_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#output\_eventhub\_namespace\_name) | The name of the Event Hub namespace used for Azure Monitor Logs monitoring. |
| <a name="output_integration_service_principal_client_id"></a> [integration\_service\_principal\_client\_id](#output\_integration\_service\_principal\_client\_id) | The client ID of the integration service principal. |
| <a name="output_integration_service_principal_object_id"></a> [integration\_service\_principal\_object\_id](#output\_integration\_service\_principal\_object\_id) | The object ID of the integration service principal. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Azure Key Vault that contains the integration service<br/>principal secrets. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group where Event Hub resources are deployed. |
<!-- END_TF_DOCS -->
