output "eventhub_by_region" {
  description = "Map of region => Event Hub connection details for all deployed regions."
  value       = local.eventhub_by_region
}

output "eventhub_consumer_group_name" {
  description = "The name of the consumer group created in each regional Event Hub."
  value       = local.eventhub_consumer_group_name
}

output "application_name" {
  description = "The display name of the Azure AD application. Returns the existing client ID when using an existing application."
  value       = var.azure_application_client_id == null ? local.app_name : var.azure_application_client_id
}

output "application_client_id" {
  description = "The client ID of the Azure AD application."
  value       = module.app_registration.client_id
}

output "service_principal_object_id" {
  description = "The object ID of the integration service principal."
  value       = module.app_registration.service_principal_object_id
}

output "key_vault_name" {
  description = <<-EOT
    The name of the Azure Key Vault that contains the integration service
    principal secrets.
  EOT
  value       = local.key_vault_name
}

output "diagnostic_settings" {
  description = "Map of AKS cluster IDs to their diagnostic setting resource IDs. Empty when create_diagnostic_settings is false."
  value = {
    for cluster_id, setting in azurerm_monitor_diagnostic_setting.aks :
    cluster_id => setting.id
  }
}
