# Workload Identity Federation (WIF) Azure Monitor Logs example.
# Secretless cloud-logs onboarding: no app registration, client secret or Key
# Vault is created in this tenant. The auth identity is the org's Upwind-minted
# multi-tenant WIF (Fetcher) app registration - the same one used by
# terraform-azurerm-onboarding. This tenant only materializes its consented
# service principal and grants it read access to the Event Hub.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Subscriptions to stream logs from.
  stream_subscription_ids = [
    "87654321-4321-4321-4321-210987654321",
  ]

  # The org's Upwind-minted WIF (Fetcher) app registration, shown in the
  # Upwind console after adding the Azure organization.
  fetcher_app_client_id = "33333333-3333-3333-3333-333333333333"
}

# ============================================================================
# PROVIDERS
# ============================================================================

provider "azurerm" {
  features {}

  # The Azure subscription ID where the Event Hub will be deployed.
  subscription_id = local.infrastructure_subscription_id
}

provider "azuread" {
  tenant_id = local.tenant_id
}

# ============================================================================
# UPWIND INTEGRATION
# ============================================================================

module "upwind_azure_cloudlogs" {
  count  = var.create ? 1 : 0
  source = "../../modules/eventhub"

  # Azure configuration.
  tenant_id                      = local.tenant_id
  infrastructure_subscription_id = local.infrastructure_subscription_id

  # Create new Event Hub.
  use_existing_eventhub = false

  # Stream from specific subscriptions.
  stream_subscription_ids = local.stream_subscription_ids

  # Workload identity federation (default true; shown here for clarity).
  # If the Terraform runner lacks Microsoft Graph permissions to create
  # service principals, pre-consent the app
  # (`az ad sp create --id <fetcher_app_client_id>`) and supply
  # fetcher_app_service_principal_object_id instead of fetcher_app_client_id.
  use_workload_identity_federation = true
  fetcher_app_client_id            = local.fetcher_app_client_id

  # Entra ID logs are optional; disable when the tenant does not allow an
  # Entra ID diagnostic setting.
  diagnostic_setting_enable_entra_logs = false
}
