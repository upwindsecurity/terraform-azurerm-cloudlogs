output "eventhub_name" {
  description = "The name of the Event Hub."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_name)
}

output "eventhub_consumer_group_name" {
  description = "The name of the Event Hub consumer group."
  value       = one(module.upwind_azure_cloudlogs[*].eventhub_consumer_group_name)
}
