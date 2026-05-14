# AKS Logs Reporter — basic example.
# Creates one Event Hub stack in the region auto-detected from the AKS cluster
# and configures diagnostic settings on the cluster to stream kube-audit logs.

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Onboarding service principal (needs Key Vault Secrets User access).
  onboarding_service_principal_client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # AKS cluster to monitor. The module auto-detects its region.
  aks_cluster_ids = [
    "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/my-rg/providers/Microsoft.ContainerService/managedClusters/my-aks",
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

  # AKS clusters to monitor — region is auto-detected from each cluster.
  aks_cluster_ids = local.aks_cluster_ids

  # Automatically create diagnostic settings on the AKS clusters.
  create_diagnostic_settings = true
}
