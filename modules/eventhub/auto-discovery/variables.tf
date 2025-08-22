variable "azure_tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID where resources will be managed."
  type        = string
}
variable "resource_group" {
  description = "Resource group name for the auto-discovery resources."
  type        = string
}

variable "created_by" {
  description = "Object ID of the principal creating the resources (used for metadata)."
  type        = string
}

variable "region" {
  description = "Azure region for resource deployment."
  type        = string
}

variable "diagnostic_settings_name" {
  description = "Name for the diagnostic settings resource."
  type        = string
}

variable "eventhub_name" {
  description = "Name of the Event Hub to send diagnostics to."
  type        = string
}

variable "eventhub_authorization_rule_id" {
  description = "Resource ID of the Event Hub authorization rule with Send claims."
  type        = string
}
