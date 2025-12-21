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

# Get all subscriptions in tenant when needed for `stream_all_subscriptions`
# or when `stream_exclude_subscription_ids` is specified without management groups.
data "azurerm_subscriptions" "all" {
  count = (
    var.stream_all_subscriptions ||
    (
      length(var.stream_exclude_subscription_ids) > 0 &&
      length(var.stream_management_group_ids) == 0
    )
    ? 1 : 0
  )
}

# Get management group details when management group IDs are specified.
data "azurerm_management_group" "streaming" {
  for_each = toset(var.stream_management_group_ids)
  name     = each.value
}

# Data source for existing service principal (when using existing app)
# Skipped if a service principal object ID is provided
data "azuread_service_principal" "existing_sp" {
  count     = local.conditional_create_application || var.azure_application_service_principal_object_id != null ? 0 : 1
  client_id = var.azure_application_client_id
}
