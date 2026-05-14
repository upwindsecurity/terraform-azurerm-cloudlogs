output "eventhub_by_region" {
  description = "Map of region => Event Hub connection details for all deployed regions."
  value       = var.create ? module.upwind_aks_logs_reporter[0].eventhub_by_region : {}
}

output "eventhub_consumer_group_name" {
  description = "Consumer group name shared across all regional Event Hubs."
  value       = var.create ? module.upwind_aks_logs_reporter[0].eventhub_consumer_group_name : null
}

output "key_vault_name" {
  description = "The name of the Key Vault holding the integration credentials."
  value       = var.create ? module.upwind_aks_logs_reporter[0].key_vault_name : null
}

output "application_client_id" {
  description = "The client ID of the Azure AD application created for the integration."
  value       = var.create ? module.upwind_aks_logs_reporter[0].application_client_id : null
}

output "diagnostic_settings" {
  description = "Map of AKS cluster IDs to their diagnostic setting resource IDs."
  value       = var.create ? module.upwind_aks_logs_reporter[0].diagnostic_settings : {}
}
