# Tenant-wide Microsoft Azure Monitor Logs with exclusions.
# This example demonstrates tenant-wide monitoring with the ability to exclude
# specific subscriptions from log streaming.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Option A: Stream from all subscriptions in tenant (uncomment to use).
  # stream_all_subscriptions = true

  # Option B: Stream from all subscriptions except excluded ones (default).
  stream_exclude_subscription_ids = [
    "12345678-1234-1234-1234-test123",     # Test subscription
    "12345678-1234-1234-1234-personal456", # Personal subscription
    "12345678-1234-1234-1234-sandbox789",  # Sandbox subscription
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

  # Tenant-wide streaming with exclusions.
  # Choose one of the following options.

  # Option A: All subscriptions (uncomment to use).
  # stream_all_subscriptions = local.stream_all_subscriptions

  # Option B: All subscriptions except excluded ones (default).
  stream_exclude_subscription_ids = local.stream_exclude_subscription_ids

  # Service principal configuration.
  onboarding_service_principal_client_id = local.onboarding_service_principal_client_id

  # Enable Entra ID logs.
  diagnostic_setting_enable_entra_logs = true
}
