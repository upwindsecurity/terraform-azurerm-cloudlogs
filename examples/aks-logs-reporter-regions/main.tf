# AKS Logs Reporter — explicit regions example.
# Creates one Event Hub stack per specified region without requiring AKS cluster
# access. Use this when cross-subscription cluster data-source access is
# unavailable, or when you want to pre-provision infrastructure before
# configuring diagnostic settings separately.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Onboarding service principal (needs Key Vault Secrets User access).
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Explicitly list the regions where Event Hub infrastructure should be
  # deployed — no AKS cluster IDs needed.
  regions = ["eastus", "westeurope"]
}

# ============================================================================
# PROVIDERS
# ============================================================================

provider "azurerm" {
  features {}
  subscription_id = local.infrastructure_subscription_id
}

provider "azuread" {
  tenant_id = local.tenant_id
}

# ============================================================================
# UPWIND INTEGRATION
# ============================================================================

module "upwind_aks_logs_reporter" {
  count  = var.create ? 1 : 0
  source = "../../modules/aks-logs-reporter"

  # Azure configuration.
  tenant_id                              = local.tenant_id
  infrastructure_subscription_id         = local.infrastructure_subscription_id
  onboarding_service_principal_client_id = local.onboarding_service_principal_client_id
  infrastructure_region                  = "eastus"

  # Explicit regions — no AKS cluster IDs required.
  regions = local.regions

  # Diagnostic settings are not created in this example because no cluster IDs
  # are provided. Configure them separately after deploying the clusters.
  create_diagnostic_settings = false
}
