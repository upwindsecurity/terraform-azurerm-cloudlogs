# Microsoft Azure Monitor Logs with management groups.
# This example demonstrates organizational-level monitoring using management
# groups with optional exclusions for specific subscriptions.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Management groups to monitor (all subscriptions under these groups).
  management_group_ids = [
    "mg-production",
    "mg-development",
  ]

  # Optional: Exclude specific subscriptions from the management groups above.
  exclude_subscription_ids = [
    "12345678-1234-1234-1234-sandbox123", # Sandbox environment
    "12345678-1234-1234-1234-legacy456",  # Legacy subscription
  ]

  # Onboarding service principal (needs Key Vault Secrets Officer access).
  onboarding_service_principal_client_id = "12345678-1234-1234-1234-5678"
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

  # Stream from management groups with exclusions.
  stream_management_group_ids     = local.management_group_ids
  stream_exclude_subscription_ids = local.exclude_subscription_ids

  # Service principal configuration.
  onboarding_service_principal_client_id = local.onboarding_service_principal_client_id

  # Enable Entra ID logs.
  diagnostic_setting_enable_entra_logs = true
}
