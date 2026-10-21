output "application_client_id" {
  description = "The client ID of the Upwind-minted WIF app registration used to read the Event Hub."
  value       = one(module.upwind_azure_cloudlogs[*].application_client_id)
}

output "service_principal_object_id" {
  description = "The object ID of the WIF service principal materialized in this tenant."
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

output "workload_identity_federation_enabled" {
  description = "Whether the secretless WIF flow was used."
  value       = one(module.upwind_azure_cloudlogs[*].workload_identity_federation_enabled)
}
