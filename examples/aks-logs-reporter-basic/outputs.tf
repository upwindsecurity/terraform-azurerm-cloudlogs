output "eventhub_by_region" {
  description = "Map of region => Event Hub connection details."
  value       = var.create ? module.upwind_aks_logs_reporter[0].eventhub_by_region : {}
}

output "key_vault_name" {
  description = "The name of the Key Vault holding the integration credentials."
  value       = var.create ? module.upwind_aks_logs_reporter[0].key_vault_name : null
}

output "application_client_id" {
  description = "The client ID of the Azure AD application created for the integration."
  value       = var.create ? module.upwind_aks_logs_reporter[0].application_client_id : null
}
