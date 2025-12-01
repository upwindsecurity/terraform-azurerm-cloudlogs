output "policy_id" {
  description = "The auto-discovery policy definition ID."
  value       = one(module.upwind_auto_discovery[*].policy_definition_id)
}

output "policy_assignment_id" {
  description = "The auto-discovery policy assignment ID."
  value       = one(module.upwind_auto_discovery[*].policy_assignment_id)
}
