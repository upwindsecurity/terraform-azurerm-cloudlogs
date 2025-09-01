# Management Groups Azure Monitor Logs Example

This example demonstrates how to use the Azure Monitor Logs module to create a new Event Hub infrastructure and enable Upwind to access logs from Azure management groups for enterprise-scale monitoring and security analysis. This approach is ideal for large organizations with structured governance using Azure management groups.

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
- `management_group_ids` - List of management group IDs to stream logs from
- `exclude_subscription_ids` - Optional list of subscriptions to exclude from the management groups
- `onboarding_service_principal_client_id` - Your onboarding service principal client ID

## Features

- **Organizational-level monitoring**: Automatically includes all subscriptions under specified management groups
- **Flexible exclusions**: Exclude specific subscriptions from management group scope
- **Dynamic discovery**: New subscriptions added to management groups are automatically included
- **Enterprise governance**: Aligns with Azure management group structure

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.30, < 4.42 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_upwind_azure_cloudlogs"></a> [upwind\_azure\_cloudlogs](#module\_upwind\_azure\_cloudlogs) | ../../modules/eventhub | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Controls whether resources should be created. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Azure AD application. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | The name of the Event Hub consumer group. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | The name of the Event Hub. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault storing secrets. |
<!-- END_TF_DOCS -->
