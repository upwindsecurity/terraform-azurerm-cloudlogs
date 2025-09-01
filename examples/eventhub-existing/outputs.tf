output "application_client_id" {
  description = "The client ID of the Azure AD application."
  value       = one(module.upwind_azure_cloudlogs[*].application_client_id)
}

output "eventhub_name" {
  description = "The name of the Event Hub."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_name)
}

output "eventhub_consumer_group_name" {
  description = "The name of the Event Hub consumer group."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_consumer_group_name)
}

output "key_vault_name" {
  description = "The name of the Key Vault storing secrets."
  value       = one(module.upwind_azure_cloudlogs[*].key_vault_name)
}
