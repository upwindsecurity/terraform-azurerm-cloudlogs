# Microsoft Azure Cloud Logs
# This example demonstrates the basic usage of the auto-discovery module, by other module
# such as `eventhub`

# ============================================================================
# CONFIGURATION
# ============================================================================

locals {
  # Replace these with your actual Azure IDs.
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"

  # Principal object id (should be inject from calling module)
  principal_object_id = "12345678-1234-1234-1234-123456789012"

  # Event Hub details (should be inject from calling module)
  eventhub_authorization_rule_id = "example-authurization-rule-id"
  eventhub_name                  = "exmpale-eventhub-name"

  # Management group ID (should be inject from calling module)
  management_group_id = "/providers/Microsoft.Management/managementGroups/mg-name"

  # Deploying policy (should be inject from calling module)
  region = "eastus"

  # Resource suffix (should be inject from calling module)
  resource_suffix = "AABBCC"

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
# UPWIND AUTO DISCOVERY MODULE
# ============================================================================

module "upwind_auto_discovery" {
  count                          = var.create ? 1 : 0
  source                         = "../../modules/auto-discovery"
  created_by                     = local.principal_object_id
  eventhub_authorization_rule_id = local.eventhub_authorization_rule_id
  eventhub_name                  = local.eventhub_name
  management_group_id            = local.management_group_id
  region                         = local.region
  resource_suffix                = local.resource_suffix
}
