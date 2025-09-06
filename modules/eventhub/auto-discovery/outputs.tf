# Policy Definition Outputs
output "policy_definition_id" {
  description = <<-EOT
    The ID of the Azure Policy definition for auto-discovery of diagnostic settings.
    This can be used to reference the policy in other Terraform configurations
    or for policy compliance reporting.
  EOT
  value = azurerm_policy_definition.auto_discovery_policy.id
}

output "policy_definition_name" {
  description = <<-EOT
    The name of the Azure Policy definition for auto-discovery.
    This is the human-readable identifier used in Azure Portal.
  EOT
  value = azurerm_policy_definition.auto_discovery_policy.name
}

# Policy Assignment Outputs
output "policy_assignment_id" {
  description = <<-EOT
    The ID of the Azure Policy assignment for auto-discovery.
    This represents the active policy enforcement on the management group.
  EOT
  value = azurerm_management_group_policy_assignment.auto_discovery.id
}

output "policy_assignment_name" {
  description = <<-EOT
    The name of the Azure Policy assignment for auto-discovery.
    This is the assignment instance name within the management group scope.
  EOT
  value = azurerm_management_group_policy_assignment.auto_discovery.name
}

output "policy_assignment_identity_principal_id" {
  description = <<-EOT
    The principal ID of the system-assigned managed identity created for
    the policy assignment. This identity is used to deploy diagnostic
    settings across subscriptions within the management group.
  EOT
  value = azurerm_management_group_policy_assignment.auto_discovery.identity[0].principal_id
}

# Custom Role Definition Outputs
output "custom_role_definition_id" {
  description = <<-EOT
    The ID of the custom RBAC role definition created for auto-discovery operations.
    This role provides specific permissions for diagnostic settings and Event Hub
    authorization rule operations.
  EOT
  value = azurerm_role_definition.custom_diagnostics_role.role_definition_resource_id
}

output "custom_role_definition_name" {
  description = <<-EOT
    The name of the custom RBAC role definition for auto-discovery.
    This is the human-readable name of the role as it appears in Azure Portal.
  EOT
  value = azurerm_role_definition.custom_diagnostics_role.name
}

# Management Group Information
output "management_group_id" {
  description = <<-EOT
    The management group ID where the auto-discovery policy is deployed.
    This shows the scope where the policy will enforce diagnostic settings
    creation across all child subscriptions.
  EOT
  value = var.management_group_id
}

output "management_group_name" {
  description = <<-EOT
    The extracted management group name from the full resource ID.
    This is used for resource naming and identification purposes.
  EOT
  value = local.management_group_name
}

# Role Assignment Information
output "role_assignments" {
  description = <<-EOT
    Summary information about the role assignments created for the policy
    assignment's managed identity. This includes both built-in and custom
    role assignments that grant necessary permissions for auto-discovery operations.
  EOT
  value = {
    builtin_roles_count = length(var.built_in_role_names)
    builtin_role_names  = var.built_in_role_names
    custom_role_assigned = true
    scope = var.management_group_id
  }
}
