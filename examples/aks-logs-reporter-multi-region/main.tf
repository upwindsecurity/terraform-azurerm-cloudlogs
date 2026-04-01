# AKS Logs Reporter — multi-region example.
# Creates one Event Hub stack per region, auto-detected from AKS clusters
# spread across several Azure regions. Diagnostic settings are configured on
# each cluster to route its logs to the Event Hub in the same region.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Onboarding service principal (needs Key Vault Secrets User access).
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # AKS clusters spread across multiple regions. The module reads each
  # cluster's location and creates one Event Hub stack per unique region.
  aks_cluster_ids = [
    # eastus clusters
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-eastus/providers/Microsoft.ContainerService/managedClusters/aks-prod-eastus",
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-eastus/providers/Microsoft.ContainerService/managedClusters/aks-staging-eastus",
    # westeurope clusters
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-westeurope/providers/Microsoft.ContainerService/managedClusters/aks-prod-westeurope",
    # southeastasia cluster
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/rg-southeastasia/providers/Microsoft.ContainerService/managedClusters/aks-prod-southeastasia",
  ]
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

  # AKS clusters — regions are auto-detected, one Event Hub stack is created
  # per unique region (eastus, westeurope, southeastasia in this example).
  aks_cluster_ids = local.aks_cluster_ids

  # Automatically create diagnostic settings on every cluster, routing each
  # cluster's logs to the Event Hub in its own region.
  create_diagnostic_settings = true

  # Optional: extend log categories beyond the default kube-audit.
  log_categories = ["kube-audit", "kube-audit-admin"]
}
