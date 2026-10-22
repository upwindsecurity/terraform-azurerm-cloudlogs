# Azure Monitor Logs Example Without a Client Secret

Grants the onboarding service principal, which Upwind already uses in your tenant, `Azure Event Hubs Data Receiver`
on the Event Hub namespace. Compared to the default flow:

- No app registration or client secret is created in your tenant.
- No Key Vault, Key Vault secrets or Key Vault role assignments are created.
- The onboarding service principal is only looked up, never created or managed by this module.
- Everything else (resource group, Event Hub namespace, Event Hub, consumer group, authorization rule, diagnostic
  settings) is created as usual.

If the Terraform runner has no Microsoft Graph permissions, also set `onboarding_service_principal_object_id` to skip
the service principal lookup.

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
- `stream_subscription_ids` - List of subscriptions to stream logs from
- `onboarding_service_principal_client_id` - The onboarding service principal client ID (from the Upwind console)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42 |

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
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the onboarding service principal used to read the Event Hub. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | The name of the Event Hub consumer group. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | The name of the Event Hub. |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | The object ID of the onboarding service principal. |
<!-- END_TF_DOCS -->
