# Azure Monitor Logs example without a client secret or Key Vault. The
# onboarding service principal, which Upwind already uses in this tenant, is
# granted read access to the Event Hub.

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

  # Onboarding service principal client ID, shown in the Upwind console.
  onboarding_service_principal_client_id = "33333333-3333-3333-3333-333333333333"
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

  # Grant the onboarding service principal read access to the Event Hub.
  # If the Terraform runner has no Microsoft Graph permissions, also set
  # onboarding_service_principal_object_id to skip the lookup.
  use_onboarding_service_principal       = true
  onboarding_service_principal_client_id = local.onboarding_service_principal_client_id

  # Entra ID logs are optional; disable when the tenant does not allow an
  # Entra ID diagnostic setting.
  diagnostic_setting_enable_entra_logs = false
}
