# Microsoft Azure Monitor Logs using existing Event Hub.
# This example integrates with your existing Event Hub infrastructure
# and creates only the necessary additional components.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Your existing Event Hub details.
  existing_resource_group_name     = "existing-eventhub-rg"
  existing_eventhub_name           = "existing-eventhub"
  existing_eventhub_namespace_name = "existing-eventhub-namespace"

  # Subscriptions to stream logs from.
  stream_subscription_ids = [
    "12345678-1234-1234-1234-123456789012", # Production
    "12345678-1234-1234-1234-123456789013", # Staging
  ]

  # Onboarding service principal (needs Key Vault Secrets Officer access).
  onboarding_service_principal_client_id = "12345678-1234-1234-1234-5678"
}

# ============================================================================
# PROVIDERS
# ============================================================================

provider "azurerm" {
  features {}

  # The Azure subscription ID where the Event Hub is located.
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

  # Use existing Event Hub.
  use_existing_eventhub   = true
  resource_group_name     = local.existing_resource_group_name
  eventhub_name           = local.existing_eventhub_name
  eventhub_namespace_name = local.existing_eventhub_namespace_name

  # Stream from specific subscriptions.
  stream_subscription_ids = local.stream_subscription_ids

  # Service principal configuration.
  onboarding_service_principal_client_id = local.onboarding_service_principal_client_id

  # Enable Entra ID logs.
  diagnostic_setting_enable_entra_logs = true
}
