# AKS Logs Reporter Module

This Terraform module creates the Azure infrastructure needed to stream AKS Kubernetes audit logs to Upwind via Azure
Event Hubs. It provisions one Event Hub stack per Azure region (auto-detected from AKS cluster locations or explicitly
specified), a shared Service Principal, and a Key Vault for storing credentials. Optionally, it configures AKS
diagnostic settings to route logs from each cluster to the Event Hub in its region.

## Usage

### Basic Usage — AKS Cluster with Auto-Detected Region

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  aks_cluster_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/my-rg/providers/Microsoft.ContainerService/managedClusters/my-aks",
  ]

  create_diagnostic_settings = true
}
```

### Explicit Regions — No AKS Cluster Access Required

Use when cross-subscription AKS data-source access is unavailable, or to pre-provision infrastructure before clusters
exist.

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  regions = ["eastus", "westeurope"]

  create_diagnostic_settings = false
}
```

### Multi-Region — Clusters Across Several Regions

The module auto-detects each cluster's region and creates one Event Hub stack per unique region.

```hcl
module "upwind_aks_logs_reporter" {
  source = "upwindsecurity/cloudlogs/azurerm//modules/aks-logs-reporter"

  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  infrastructure_region                  = "eastus"

  aks_cluster_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-eastus/providers/Microsoft.ContainerService/managedClusters/aks-prod-eastus",
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-westeurope/providers/Microsoft.ContainerService/managedClusters/aks-prod-westeurope",
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-southeastasia/providers/Microsoft.ContainerService/managedClusters/aks-prod-southeastasia",
  ]

  create_diagnostic_settings = true
  log_categories             = ["kube-audit", "kube-audit-admin"]
}
```

## Region Selection

The module determines which regions to deploy Event Hub infrastructure into using the following logic:

- **Auto-detection**: When `aks_cluster_ids` is provided, the module reads each cluster's location and deploys one
  Event Hub stack per unique region.
- **Explicit regions**: When `regions` is provided, Event Hub stacks are created in those regions directly — no AKS
  cluster access needed.
- **Combined**: Both can be used together; the union of detected and explicit regions is used.

At least one of `aks_cluster_ids` or `regions` must be non-empty.

## Diagnostic Settings

Setting `create_diagnostic_settings = true` (requires `aks_cluster_ids` to be non-empty) will create
`azurerm_monitor_diagnostic_setting` resources on each AKS cluster, routing its logs to the Event Hub deployed in the
same region. If you prefer to manage diagnostic settings separately, set `create_diagnostic_settings = false` and use
the `eventhub_by_region` output to configure them.

## Examples

See the [examples](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/) directory:

- **[aks-logs-reporter-basic](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-basic/)**:
  Single cluster with auto-detected region and diagnostic settings
- **[aks-logs-reporter-regions](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-regions/)**:
  Explicit regions without AKS cluster access
- **[aks-logs-reporter-multi-region](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/aks-logs-reporter-multi-region/)**:
  Multiple clusters spread across several Azure regions

## Prerequisites

- Azure subscription with appropriate permissions
- Azure AD tenant access
- Terraform >= 1.9
- Azure CLI or service principal authentication

## Permissions Required

- **Subscription level**: `Contributor` or `Owner` on the infrastructure subscription
- **Azure AD level**: `Application Administrator` or `Cloud Application Administrator`
- **AKS clusters** (when using `aks_cluster_ids`): read access (`Reader`) to each cluster

> **Note:** The `Monitoring Reader` role is granted on the infrastructure subscription only.
> If AKS clusters reside in other subscriptions, you must manually grant `Monitoring Reader`
> to the integration service principal in each of those subscriptions.

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
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_registration"></a> [app\_registration](#module\_app\_registration) | ../_shared/app-registration | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.regions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.regions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.regions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.regions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_key_vault.integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.sp_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.sp_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.regions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.eh_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.monitoring_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_service_principal.onboarding_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current_sp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_cluster.clusters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_ids"></a> [aks\_cluster\_ids](#input\_aks\_cluster\_ids) | List of AKS cluster resource IDs used to auto-detect the Azure regions<br/>where Event Hub infrastructure should be deployed. The module reads each<br/>cluster's location and creates one Event Hub stack per unique region.<br/>Requires read access to the AKS clusters via the configured provider.<br/>At least one of `aks_cluster_ids` or `regions` must be non-empty. | `list(string)` | `[]` | no |
| <a name="input_application_name_prefix"></a> [application\_name\_prefix](#input\_application\_name\_prefix) | The Upwind AD application display name prefix. | `string` | `"upwindsecurity-aks-logs"` | no |
| <a name="input_application_owners"></a> [application\_owners](#input\_application\_owners) | List of user IDs that will be set as owners of the Azure application &<br/>service principal. Each ID should be in the form of a GUID. If this list<br/>is left empty, the owner defaults to the authenticated principal. | `list(string)` | `[]` | no |
| <a name="input_application_password_expiration_date"></a> [application\_password\_expiration\_date](#input\_application\_password\_expiration\_date) | The expiration date for the Azure AD application password in RFC3339 format<br/>(e.g., `2999-12-31T23:59:59Z`). This determines when the application<br/>password expires. | `string` | `"2999-12-31T23:59:59Z"` | no |
| <a name="input_azure_application_client_id"></a> [azure\_application\_client\_id](#input\_azure\_application\_client\_id) | Optional client ID of an existing Azure AD application. If provided, the module will use this existing application instead of creating a new one. | `string` | `null` | no |
| <a name="input_azure_application_client_secret"></a> [azure\_application\_client\_secret](#input\_azure\_application\_client\_secret) | Client secret for the existing Azure AD application. Required when azure\_application\_client\_id is provided. | `string` | `null` | no |
| <a name="input_azure_application_service_principal_object_id"></a> [azure\_application\_service\_principal\_object\_id](#input\_azure\_application\_service\_principal\_object\_id) | The service principal object ID of the existing Azure AD application. Optional — if provided the module will skip looking up the service principal object ID. | `string` | `null` | no |
| <a name="input_create_diagnostic_settings"></a> [create\_diagnostic\_settings](#input\_create\_diagnostic\_settings) | Whether to automatically create AKS diagnostic settings to stream logs to<br/>the Event Hub. When true, requires `aks_cluster_ids` to be non-empty.<br/>Set to false if you only want the Event Hub infrastructure without<br/>configuring AKS clusters. | `bool` | `true` | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | The name of the diagnostic setting to be created on each AKS cluster. | `string` | `"upwind-aks-audit"` | no |
| <a name="input_eventhub_authorization_rule_name"></a> [eventhub\_authorization\_rule\_name](#input\_eventhub\_authorization\_rule\_name) | The name prefix for the authorization rule to be created. The region and resource suffix will be appended. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#input\_eventhub\_consumer\_group\_name) | The name prefix for the consumer group to be created. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_eventhub_enable_auto_inflate"></a> [eventhub\_enable\_auto\_inflate](#input\_eventhub\_enable\_auto\_inflate) | Whether to enable Event Hub namespace auto-inflate. | `bool` | `true` | no |
| <a name="input_eventhub_max_throughput_units"></a> [eventhub\_max\_throughput\_units](#input\_eventhub\_max\_throughput\_units) | The maximum number of throughput units when auto-inflate is enabled. | `number` | `20` | no |
| <a name="input_eventhub_message_retention_days"></a> [eventhub\_message\_retention\_days](#input\_eventhub\_message\_retention\_days) | The retention period for messages in the Event Hub, in days. | `number` | `1` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name prefix for the Event Hub. The region and resource suffix will be appended. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | The name prefix for the Event Hub namespace. The region and resource suffix will be appended. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_eventhub_partition_count"></a> [eventhub\_partition\_count](#input\_eventhub\_partition\_count) | The number of partitions of the Event Hub. | `number` | `4` | no |
| <a name="input_eventhub_pricing_tier"></a> [eventhub\_pricing\_tier](#input\_eventhub\_pricing\_tier) | The pricing tier of the Event Hub Namespace. | `string` | `"Standard"` | no |
| <a name="input_infrastructure_region"></a> [infrastructure\_region](#input\_infrastructure\_region) | The Azure region where all global/shared resources are created (Key Vault,<br/>shared resource group, etc.). | `string` | n/a | yes |
| <a name="input_infrastructure_subscription_id"></a> [infrastructure\_subscription\_id](#input\_infrastructure\_subscription\_id) | The subscription ID where the infrastructure resources (Event Hub, Key<br/>Vault, Service Principal, etc.) will be deployed or already exist. This<br/>must match the subscription context of your authenticated Azure provider. | `string` | n/a | yes |
| <a name="input_key_vault_client_id_secret_name"></a> [key\_vault\_client\_id\_secret\_name](#input\_key\_vault\_client\_id\_secret\_name) | The name of the Key Vault secret for service principal client ID. | `string` | `"sp-client-id"` | no |
| <a name="input_key_vault_client_secret_secret_name"></a> [key\_vault\_client\_secret\_secret\_name](#input\_key\_vault\_client\_secret\_secret\_name) | The name of the Key Vault secret for service principal client secret. | `string` | `"sp-client-secret"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the Key Vault used to store integration service principal<br/>secrets and credentials. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_key_vault_network_acls_bypass"></a> [key\_vault\_network\_acls\_bypass](#input\_key\_vault\_network\_acls\_bypass) | Specifies which traffic can bypass the network rules. Possible values are<br/>`AzureServices` and `None`. Only used when `key_vault_network_acls_enabled` is `true`. | `string` | `"AzureServices"` | no |
| <a name="input_key_vault_network_acls_default_action"></a> [key\_vault\_network\_acls\_default\_action](#input\_key\_vault\_network\_acls\_default\_action) | The default action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`.<br/>Possible values are `Allow` and `Deny`. Only used when `key_vault_network_acls_enabled` is `true`. | `string` | `"Deny"` | no |
| <a name="input_key_vault_network_acls_enabled"></a> [key\_vault\_network\_acls\_enabled](#input\_key\_vault\_network\_acls\_enabled) | Whether to enable network ACLs for the Key Vault. When enabled, network<br/>access rules will be applied based on the other network ACL variables. | `bool` | `false` | no |
| <a name="input_key_vault_network_acls_ip_rules"></a> [key\_vault\_network\_acls\_ip\_rules](#input\_key\_vault\_network\_acls\_ip\_rules) | One or more IP addresses or CIDR blocks which should be able to access<br/>the Key Vault. Only used when `key_vault_network_acls_enabled` is `true`. | `list(string)` | `[]` | no |
| <a name="input_key_vault_network_acls_virtual_network_subnet_ids"></a> [key\_vault\_network\_acls\_virtual\_network\_subnet\_ids](#input\_key\_vault\_network\_acls\_virtual\_network\_subnet\_ids) | One or more subnet IDs which should be able to access this Key Vault.<br/>Only used when `key_vault_network_acls_enabled` is `true`. | `list(string)` | `[]` | no |
| <a name="input_key_vault_purge_protection_enabled"></a> [key\_vault\_purge\_protection\_enabled](#input\_key\_vault\_purge\_protection\_enabled) | Whether to enable purge protection for the Key Vault. | `bool` | `true` | no |
| <a name="input_key_vault_rbac_authorization_enabled"></a> [key\_vault\_rbac\_authorization\_enabled](#input\_key\_vault\_rbac\_authorization\_enabled) | Whether to enable RBAC authorization for the Key Vault. | `bool` | `true` | no |
| <a name="input_key_vault_region"></a> [key\_vault\_region](#input\_key\_vault\_region) | The Azure region where the Key Vault and its resource group will be created.<br/>Defaults to `infrastructure_region` when not set. | `string` | `null` | no |
| <a name="input_key_vault_secret_expiration_date"></a> [key\_vault\_secret\_expiration\_date](#input\_key\_vault\_secret\_expiration\_date) | The expiration date for the Key Vault secrets in RFC3339 format<br/>(e.g., `2025-12-31T23:59:59Z`). If not specified, secrets will not expire. | `string` | `null` | no |
| <a name="input_key_vault_sku_name"></a> [key\_vault\_sku\_name](#input\_key\_vault\_sku\_name) | The SKU name of the Key Vault. | `string` | `"standard"` | no |
| <a name="input_log_categories"></a> [log\_categories](#input\_log\_categories) | List of log categories to enable for AKS diagnostic settings.<br/>Common categories: kube-audit, kube-audit-admin, kube-apiserver,<br/>kube-controller-manager, kube-scheduler, cluster-autoscaler. | `list(string)` | <pre>[<br/>  "kube-audit"<br/>]</pre> | no |
| <a name="input_onboarding_service_principal_client_id"></a> [onboarding\_service\_principal\_client\_id](#input\_onboarding\_service\_principal\_client\_id) | The client ID of the Upwind onboarding service principal. This service<br/>principal will be granted Key Vault Secrets User access to read<br/>the integration service principal secrets. | `string` | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | Explicit list of Azure regions in which to create Event Hub infrastructure.<br/>Used when cross-subscription AKS data-source access is unavailable, or to<br/>add extra regions beyond those auto-detected from `aks_cluster_ids`.<br/>At least one of `aks_cluster_ids` or `regions` must be non-empty. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name prefix for resource groups created by this module. The region and resource suffix will be appended. | `string` | `"upwindsecurity-aks"` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | The suffix to append to all resources created by this module. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure Tenant that will be onboarded to Upwind for AKS audit logs monitoring. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Azure AD application. |
| <a name="output_application_name"></a> [application\_name](#output\_application\_name) | The display name of the Azure AD application. Null when using an existing application. |
| <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings) | Map of AKS cluster IDs to their diagnostic setting resource IDs. Empty when create\_diagnostic\_settings is false. |
| <a name="output_eventhub_by_region"></a> [eventhub\_by\_region](#output\_eventhub\_by\_region) | Map of region => Event Hub connection details for all deployed regions. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | The name of the consumer group created in each regional Event Hub. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Azure Key Vault that contains the integration service<br/>principal secrets. |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | The object ID of the integration service principal. |
<!-- END_TF_DOCS -->
