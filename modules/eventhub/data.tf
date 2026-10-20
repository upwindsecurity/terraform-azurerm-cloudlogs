# Get current Azure AD client configuration for resource setup.
data "azuread_client_config" "current" {}

# Get current subscription context to validate against `infrastructure_subscription_id`.
data "azurerm_subscription" "current" {}

# Get onboarding service principal details. This is the identity Upwind already
# holds credentials for; it is granted read access to the Event Hub directly.
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
