# AKS Logs Reporter — Multi-Region Example

This example demonstrates how to use the AKS Logs Reporter module with AKS clusters spread across multiple Azure regions.
The module auto-detects each cluster's region and creates one Event Hub stack per unique region. Diagnostic settings are
configured on each cluster to route logs to the Event Hub in the same region, minimising cross-region data transfer.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Configuration

Before running this example, update the `locals` block in `main.tf` with your actual Azure configuration:

- `tenant_id` - Your Azure tenant ID
- `infrastructure_subscription_id` - The subscription where Event Hub infrastructure will be deployed
- `onboarding_service_principal_client_id` - Your onboarding service principal client ID
- `aks_cluster_ids` - List of AKS cluster resource IDs spread across multiple regions

## Features

- **Multi-region support**: One Event Hub stack is created per unique region derived from the provided cluster IDs
- **Region-local routing**: Each cluster's diagnostic settings point to the Event Hub in the same region
- **Configurable log categories**: Extend beyond the default `kube-audit` by setting `log_categories`
- **Automatic diagnostic settings**: All clusters are configured automatically in a single apply

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_upwind_aks_logs_reporter"></a> [upwind\_aks\_logs\_reporter](#module\_upwind\_aks\_logs\_reporter) | ../../modules/aks-logs-reporter | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create the resources. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Azure AD application created for the integration. |
| <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings) | Map of AKS cluster IDs to their diagnostic setting resource IDs. |
| <a name="output_eventhub_by_region"></a> [eventhub\_by\_region](#output\_eventhub\_by\_region) | Map of region => Event Hub connection details for all deployed regions. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | Consumer group name shared across all regional Event Hubs. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault holding the integration credentials. |
<!-- END_TF_DOCS -->
