# Get current Azure AD client configuration for resource setup.
data "azuread_client_config" "current" {}

# Get current Azure client configuration for service principal details.
data "azurerm_client_config" "current_sp" {}

# Get current subscription context to validate against `infrastructure_subscription_id`.
data "azurerm_subscription" "current" {}

# Get onboarding service principal details for Key Vault access.
data "azuread_service_principal" "onboarding_sp" {
  client_id = var.onboarding_service_principal_client_id
}

# Data source for existing service principal (when using existing app).
# Skipped if a service principal object ID is provided.
data "azuread_service_principal" "existing_sp" {
  count     = local.conditional_create_application || var.azure_application_service_principal_object_id != null ? 0 : 1
  client_id = var.azure_application_client_id
}

# Look up each AKS cluster to read its location for region auto-detection and
# diagnostic settings routing.
data "azurerm_kubernetes_cluster" "clusters" {
  for_each            = local.aks_cluster_refs
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
