output "client_id" {
  description = "The client ID of the Azure AD application (new or existing)."
  value       = local.client_id
}

output "client_secret" {
  description = "The client secret of the Azure AD application. Null when using an existing application without a provided secret."
  value       = local.client_secret
  sensitive   = true
}

output "service_principal_object_id" {
  description = "The object ID of the service principal (new or existing)."
  value       = local.service_principal_object_id
}
