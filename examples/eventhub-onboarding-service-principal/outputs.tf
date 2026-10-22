output "application_client_id" {
  description = "The client ID of the onboarding service principal used to read the Event Hub."
  value       = one(module.upwind_azure_cloudlogs[*].application_client_id)
}

output "service_principal_object_id" {
  description = "The object ID of the onboarding service principal."
  value       = one(module.upwind_azure_cloudlogs[*].service_principal_object_id)
}

output "eventhub_name" {
  description = "The name of the Event Hub."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_name)
}

output "eventhub_consumer_group_name" {
  description = "The name of the Event Hub consumer group."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_consumer_group_name)
}
