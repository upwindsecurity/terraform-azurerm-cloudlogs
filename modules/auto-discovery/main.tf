# This auto-discovery module configures Azure Policy for automatic deployment
# of diagnostic settings to stream Azure Activity Logs from subscriptions to
# an Event Hub. It creates a custom Azure Policy definition and assignment at
# the management group level with system-assigned managed identity for automated
# deployment of diagnostic settings across subscriptions.

locals {
  # Extract management group name from the full resource ID for resource naming
  # Example: "/providers/Microsoft.Management/managementGroups/my-mg" -> "my-mg"
  management_group_name = basename(var.management_group_id)

  # Collect role definition IDs for policy definition
  # Use role_definition_resource_id for clean role definition IDs
  all_role_definition_ids = (
    concat(
      [
        for role_name in var.built_in_role_names :
        data.azurerm_role_definition.built_in_role[role_name].id
      ],
      [
        azurerm_role_definition.custom_diagnostics_role.role_definition_resource_id
      ]
    )
  )

  policy_name = (
    format(
      "%s-%s",
      var.policy_name,
      var.resource_suffix
    )
  )

  role_definition_name = (
    format(
      "%s-%s-%s",
      var.custom_role_name,
      local.management_group_name,
      var.resource_suffix
    )
  )
}

# Data source to retrieve Azure RBAC role definitions by name.
# These roles will be assigned to the policy assignment's managed identity
# to grant necessary permissions for deploying diagnostic settings.
data "azurerm_role_definition" "built_in_role" {
  for_each = toset(var.built_in_role_names)
  name     = each.key
}

# Custom RBAC role definition for CloudLogs diagnostic settings operations.
# This role provides specific permissions needed for diagnostic settings management
# and Event Hub authorization rule operations required by the auto-discovery policy.
resource "azurerm_role_definition" "custom_diagnostics_role" {
  name        = local.role_definition_name
  scope       = var.management_group_id
  description = "Custom role for Upwind CloudLogs auto-discovery module"

  permissions {
    actions = var.custom_role_actions
  }

  assignable_scopes = [var.management_group_id]
}

# Custom Azure Policy definition for automatic deployment of diagnostic settings.
# This policy defines the rules and deployment template for creating diagnostic
# settings that stream Azure Activity Logs to an Event Hub when they don't exist.
resource "azurerm_policy_definition" "policy_definition" {
  name                = local.policy_name
  display_name        = local.policy_name
  policy_type         = "Custom"
  mode                = "All"
  description         = var.policy_description
  management_group_id = var.management_group_id

  # Policy parameters definition
  parameters = jsonencode(local.policy_parameters)

  # Policy rule definition
  policy_rule = jsonencode(local.policy_rule)

  # Policy metadata for organization and tracking purposes.
  metadata = jsonencode({
    category  = var.policy_category
    createdBy = var.created_by
    createdOn = timestamp()
    updatedBy = null
    updatedOn = null
  })
}

# Azure Policy assignment at the management group level.
# Assigns the auto-discovery policy to the specified management group with a
# system-assigned managed identity that will be used to deploy diagnostic settings.
resource "azurerm_management_group_policy_assignment" "policy_assignment" {
  name                 = local.policy_name
  display_name         = local.policy_name
  location             = var.region
  policy_definition_id = azurerm_policy_definition.policy_definition.id
  management_group_id  = var.management_group_id

  # Policy parameters with Event Hub configuration for diagnostic settings
  parameters = jsonencode({
    eventHubAuthRuleId = { value = var.eventhub_authorization_rule_id }
    eventHubName       = { value = var.eventhub_name }
  })

  # System-assigned managed identity for policy deployment operations
  identity {
    type = "SystemAssigned"
  }
}

# Role assignments for built-in roles to policy assignment managed identity.
# Creates role assignments for each built-in role on the management group.
resource "azurerm_role_assignment" "policy_builtin_roles" {
  for_each = toset(var.built_in_role_names)

  scope              = var.management_group_id
  role_definition_id = data.azurerm_role_definition.built_in_role[each.value].role_definition_id
  principal_id       = azurerm_management_group_policy_assignment.policy_assignment.identity[0].principal_id

  depends_on = [
    azurerm_management_group_policy_assignment.policy_assignment
  ]
}

# Role assignment for custom role to policy assignment managed identity.
# Creates role assignment for the custom role on the management group.
resource "azurerm_role_assignment" "policy_custom_role" {
  scope              = var.management_group_id
  role_definition_id = azurerm_role_definition.custom_diagnostics_role.role_definition_resource_id
  principal_id       = azurerm_management_group_policy_assignment.policy_assignment.identity[0].principal_id

  depends_on = [
    azurerm_management_group_policy_assignment.policy_assignment,
    azurerm_role_definition.custom_diagnostics_role
  ]
}
