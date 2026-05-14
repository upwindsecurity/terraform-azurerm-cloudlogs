# AKS Logs Reporter — Explicit Regions Example

This example demonstrates how to use the AKS Logs Reporter module when you want to pre-provision Event Hub infrastructure
in specific regions without requiring access to the AKS cluster data source. This is useful when AKS clusters live in
different subscriptions, or when you want to deploy infrastructure before configuring diagnostic settings separately.

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
- `infrastructure_subscription_id` - The subscription where Event Hub will be deployed
- `onboarding_service_principal_client_id` - Your onboarding service principal client ID
- `regions` - List of Azure regions where Event Hub infrastructure should be deployed

## Features

- **No AKS cluster access required**: Regions are specified explicitly, so no cross-subscription cluster data-source access is needed
- **Pre-provision infrastructure**: Deploy Event Hub stacks before clusters exist or before diagnostic settings are configured
- **Separate diagnostic settings**: Use the `eventhub_by_region` output to configure diagnostic settings independently

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
| <a name="output_eventhub_by_region"></a> [eventhub\_by\_region](#output\_eventhub\_by\_region) | Map of region => Event Hub connection details. Pass this to configure diagnostic settings on AKS clusters separately. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | Consumer group name to use when configuring diagnostic settings separately. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault holding the integration credentials. |
<!-- END_TF_DOCS -->
