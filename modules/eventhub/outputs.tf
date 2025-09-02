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
  description = "The display name of the Azure AD application."
  value       = local.app_name
}

output "application_client_id" {
  description = "The client ID of the Azure AD application."
  value       = azuread_application.integration.client_id
}

output "key_vault_name" {
  description = <<-EOT
    The name of the Azure Key Vault that contains the integration service
    principal secrets.
  EOT
  value       = local.key_vault_name
}

output "integration_service_principal_client_id" {
  description = "The client ID of the integration service principal."
  value       = azuread_service_principal.integration.client_id
}

output "integration_service_principal_object_id" {
  description = "The object ID of the integration service principal."
  value       = azuread_service_principal.integration.object_id
}
