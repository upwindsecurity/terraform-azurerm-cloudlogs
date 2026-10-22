output "eventhub_name" {
  description = "The name of the Event Hub used for Azure Monitor Logs monitoring."
  value       = local.eventhub_name
}

output "eventhub_namespace_name" {
  description = "The name of the Event Hub namespace used for Azure Monitor Logs monitoring."
  value       = local.eventhub_namespace_name
}

output "eventhub_consumer_group_name" {
  description = "The name of the consumer group created for processing logs."
  value       = local.eventhub_consumer_group_name
}

output "resource_group_name" {
  description = "The name of the resource group where Event Hub resources are deployed."
  value       = local.resource_group_name
}

output "application_name" {
  description = "The display name of the Azure AD application. Null when the onboarding service principal is used."
  value       = var.use_onboarding_service_principal ? null : (local.conditional_create_application ? local.app_name : var.azure_application_client_id)
}

output "application_client_id" {
  description = "The client ID of the Azure AD application, or of the onboarding service principal when it is used."
  value       = local.application_client_id
}

output "service_principal_object_id" {
  description = "The object ID of the integration service principal."
  value       = local.service_principal_object_id
}

output "key_vault_name" {
  description = <<-EOT
    The name of the Azure Key Vault that contains the integration service
    principal secrets. Null when the onboarding service principal is used.
  EOT
  value       = local.conditional_create_key_vault ? local.key_vault_name : null
}
