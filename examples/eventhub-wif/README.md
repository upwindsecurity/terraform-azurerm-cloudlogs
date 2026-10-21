# Workload Identity Federation (WIF) Azure Monitor Logs Example

Secretless cloud-logs onboarding. Instead of creating an app registration and
client secret in your tenant and storing them in a Key Vault, the module
materializes the consented service principal of your organization's
Upwind-minted WIF app registration (the same `fetcher_app_client_id` used by
[terraform-azurerm-onboarding](https://github.com/upwindsecurity/terraform-azurerm-onboarding))
and grants it `Azure Event Hubs Data Receiver` on the Event Hub namespace.
Upwind reads the Event Hub as that app via workload identity federation - no
client secret exists or is transferred.

Compared to the legacy flow (`use_workload_identity_federation = false`, or no
`fetcher_*` input supplied):

- No `azuread_application` / application password is created in your tenant.
- No Key Vault, Key Vault secrets or Key Vault role assignments are created.
- `onboarding_service_principal_client_id` is not required.
- Everything else (resource group, Event Hub namespace, Event Hub, consumer
  group, authorization rule, diagnostic settings) is created as usual.

If the Terraform runner lacks Microsoft Graph permissions to create service
principals, pre-consent the app registration (e.g. via
`az ad sp create --id <fetcher_app_client_id>`) and supply
`fetcher_app_service_principal_object_id` instead of `fetcher_app_client_id`.

Requires the organization to be WIF-enabled on the Upwind side.

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
- `fetcher_app_client_id` - The org's Upwind-minted WIF app registration client ID (from the Upwind console)

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
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Upwind-minted WIF app registration used to read the Event Hub. |
| <a name="output_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#output\_eventhub\_consumer\_group\_name) | The name of the Event Hub consumer group. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | The name of the Event Hub. |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | The object ID of the WIF service principal materialized in this tenant. |
| <a name="output_workload_identity_federation_enabled"></a> [workload\_identity\_federation\_enabled](#output\_workload\_identity\_federation\_enabled) | Whether the secretless WIF flow was used. |
<!-- END_TF_DOCS -->
