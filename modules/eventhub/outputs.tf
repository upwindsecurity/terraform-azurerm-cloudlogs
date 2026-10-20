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
