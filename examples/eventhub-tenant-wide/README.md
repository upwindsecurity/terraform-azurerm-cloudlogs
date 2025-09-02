# Tenant-Wide Azure Monitor Logs Example

This example demonstrates how to use the Azure Monitor Logs module to create a new Event Hub infrastructure and enable Upwind to access logs from all subscriptions in your Azure tenant, with the ability to exclude specific subscriptions. This approach is ideal for comprehensive tenant-wide monitoring while maintaining control over which subscriptions to exclude.

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
- `stream_exclude_subscription_ids` - List of subscription IDs to exclude from monitoring
- `onboarding_service_principal_client_id` - Your onboarding service principal client ID

## Streaming Options

This example provides two tenant-wide streaming options:

### Option A: All Subscriptions (No Exclusions)
```hcl
stream_all_subscriptions = true
```
Streams logs from every subscription in the tenant.

### Option B: All Subscriptions with Exclusions (Default)
```hcl
stream_exclude_subscription_ids = [
  "12345678-1234-1234-1234-test123",     # Test subscription
  "12345678-1234-1234-1234-personal456", # Personal subscription
  "12345678-1234-1234-1234-sandbox789",  # Sandbox subscription
]
```
Streams logs from all subscriptions except the specified ones.

## Features

- **Comprehensive coverage**: Monitor all subscriptions in your Azure tenant
- **Flexible exclusions**: Exclude test, personal, or sandbox subscriptions
- **Dynamic discovery**: New subscriptions are automatically included (unless excluded)
- **Centralized monitoring**: Single integration point for entire tenant
- **Cost control**: Exclude non-production subscriptions to manage costs

## Use Cases

- **Enterprise-wide monitoring**: Complete visibility across all Azure subscriptions
- **Compliance requirements**: Ensure all production workloads are monitored
- **Security oversight**: Comprehensive security monitoring across the organization
- **Cost optimization**: Exclude development/test subscriptions to reduce ingestion costs

## Prerequisites

This example requires:

- **Tenant-level permissions**: Ability to read all subscriptions in the tenant
- **Subscription permissions**: Contributor access to create diagnostic settings on all included subscriptions
- **Azure AD permissions**: Application Administrator or custom role for service principal creation

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
