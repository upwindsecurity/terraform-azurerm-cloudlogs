# AKS Logs Reporter — Basic Example

This example demonstrates how to use the AKS Logs Reporter module to stream kube-audit logs from AKS clusters to Upwind.
The module auto-detects the region from each cluster and creates one Event Hub stack in that region, then configures
diagnostic settings on the cluster automatically.

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
- `aks_cluster_ids` - List of AKS cluster resource IDs to monitor

## Features

- **Auto-detected region**: The module reads the AKS cluster location and deploys Event Hub infrastructure in the same region
- **Automatic diagnostic settings**: Configures diagnostic settings on each cluster to stream kube-audit logs
- **Minimal configuration**: Only AKS cluster IDs are required — no need to specify regions manually

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
| <a name="output_eventhub_by_region"></a> [eventhub\_by\_region](#output\_eventhub\_by\_region) | Map of region => Event Hub connection details. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault holding the integration credentials. |
<!-- END_TF_DOCS -->
