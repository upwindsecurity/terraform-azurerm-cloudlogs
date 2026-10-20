# region azure_integration_scope

variable "tenant_id" {
  description = "The Azure Tenant that will be onboarded to the Upwind Azure Monitor Logs monitoring."
  type        = string
}

variable "infrastructure_subscription_id" {
  description = <<-EOT
    The subscription ID where the infrastructure resources (Event Hub and
    related resources) will be deployed or already exist. This must match the
    subscription context of your authenticated Azure provider.
  EOT
  type        = string

  validation {
    condition = (
      var.infrastructure_subscription_id == data.azurerm_subscription.current.subscription_id
    )
    error_message = <<-EOT
      The `infrastructure_subscription_id` must match your current Azure provider
      subscription context. Either update the variable value or configure your
      Azure provider with the correct `subscription_id`.
    EOT
  }
}

variable "onboarding_service_principal_client_id" {
  description = <<-EOT
    The client ID of the Upwind onboarding service principal. Upwind already
    holds credentials for this principal; it is granted Azure Event Hubs Data
    Receiver on the Event Hub namespace and Monitoring Reader on the
    infrastructure subscription so it can consume the log stream.
  EOT
  type        = string
}

# endregion azure_integration_scope

# region eventhub_configuration

variable "eventhub_name" {
  description = "The name of the Event Hub to be created or the existing one."
  type        = string
  default     = "upwindsecurity"
}

variable "eventhub_namespace_name" {
  description = <<-EOT
    The name of the Event Hub namespace to be created or the existing one.
  EOT
  type        = string
  default     = "upwindsecurity"
}

variable "eventhub_pricing_tier" {
  description = "The pricing tier of the Event Hub Namespace."
  type        = string
  default     = "Standard"
}

variable "eventhub_enable_auto_inflate" {
  description = "Whether to enable Event Hub namespace auto-inflate."
  type        = bool
  default     = true
}

variable "eventhub_max_throughput_units" {
  description = <<-EOT
    The maximum number of throughput units when auto-inflate is enabled.
  EOT
  type        = number
  default     = 20
}

variable "eventhub_message_retention_days" {
  description = "The retention period for messages in the Event Hub, in days."
  type        = number
  default     = 1
}

variable "eventhub_partition_count" {
  description = "The number of partitions of the Event Hub."
  type        = number
  default     = 4
}

variable "eventhub_consumer_group_name" {
  description = "The name of the consumer group to be created."
  type        = string
  default     = "upwindsecurity"
}

variable "eventhub_authorization_rule_name" {
  description = "The name of the authorization rule to be created."
  type        = string
  default     = "upwindsecurity"
}

# endregion eventhub_configuration

# region module_behavior

variable "use_existing_eventhub" {
  description = <<-EOT
    Whether to use an existing Event Hub. If false, create a new one.
  EOT
  type        = bool
  default     = false
}

variable "use_existing_resource_group" {
  description = <<-EOT
    Whether to use an existing resource group. If false, create a new one.
  EOT
  type        = bool
  default     = false
}

# endregion module_behavior

# region diagnostic_settings

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting to be created."
  type        = string
  default     = "upwindsecurity"
}

variable "diagnostic_setting_activity_log_categories" {
  description = <<-EOT
    List of activity log categories to enable in the diagnostic setting.
    Currently, only `Administrative` and `Security` categories are
    supported by Upwind. Do not modify unless instructed by Upwind support.
  EOT
  type        = list(string)
  default = [
    "Administrative",
    "Security"
  ]

  validation {
    condition = alltrue([
      for category in var.diagnostic_setting_activity_log_categories :
      contains(["Administrative", "Security"], category)
    ])
    error_message = <<-EOT
      Only `Administrative` and `Security` log categories are currently supported by Upwind.
    EOT
  }
}

variable "diagnostic_setting_enable_entra_logs" {
  description = "Whether to enable or disable Entra logs."
  type        = bool
  default     = true
}

variable "diagnostic_setting_entra_name" {
  description = <<-EOT
    The name of the Entra diagnostic setting to be created.
  EOT
  type        = string
  default     = "upwindsecurity-entra"
}

variable "diagnostic_setting_entra_log_categories" {
  description = <<-EOT
    List of Entra ID log categories to enable in the diagnostic setting.
    Currently, only `AuditLogs` and `SignInLogs` categories are
    supported by Upwind. Do not modify unless instructed by Upwind support.
  EOT
  type        = list(string)
  default = [
    "AuditLogs",
    "SignInLogs"
  ]

  validation {
    condition = alltrue([
      for category in var.diagnostic_setting_entra_log_categories :
      contains(["AuditLogs", "SignInLogs"], category)
    ])
    error_message = <<-EOT
      Only `AuditLogs` and `SignInLogs` categories are currently supported by Upwind.
    EOT
  }
}

# endregion diagnostic_settings

# region streaming_scope

variable "stream_all_subscriptions" {
  description = <<-EOT
    When set to true, create diagnostic settings to stream logs from ALL
    subscriptions within the tenant to the Event Hub. Overrides
    `stream_subscription_ids` and `stream_management_group_ids`.
  EOT
  type        = bool
  default     = false
}

variable "stream_management_group_ids" {
  description = <<-EOT
    List of management group IDs to include all subscriptions from for log
    streaming. All subscriptions under these management groups (including
    nested management groups) will have diagnostic settings created to stream
    logs to the Event Hub. Can be combined with `stream_exclude_subscription_ids`
    to exclude specific subscriptions. Mutually exclusive with `stream_subscription_ids`.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = !(
      length(var.stream_management_group_ids) > 0 &&
      length(var.stream_subscription_ids) > 0
    )
    error_message = <<-EOT
      `stream_management_group_ids` and `stream_subscription_ids` are mutually
      exclusive. Use management groups (optionally with exclusions) for
      organizational-level selection, or specific subscription IDs for
      targeted selection.
    EOT
  }
}

variable "stream_subscription_ids" {
  description = <<-EOT
    List of subscription IDs to create diagnostic settings for, streaming
    their logs to the Event Hub. If `stream_all_subscriptions` is false and
    this list is empty, only the current subscription will have its logs
    streamed. This variable is mutually exclusive with
    `stream_exclude_subscription_ids`.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = !(
      length(var.stream_subscription_ids) > 0 &&
      length(var.stream_exclude_subscription_ids) > 0
    )
    error_message = <<-EOT
      `stream_subscription_ids` and `stream_exclude_subscription_ids` are
      mutually exclusive. Use `stream_subscription_ids` for specific subscriptions,
      or `stream_exclude_subscription_ids` to exclude from all/management groups.
    EOT
  }
}

variable "stream_exclude_subscription_ids" {
  description = <<-EOT
    List of subscription IDs to exclude from log streaming. When specified,
    diagnostic settings will be created for all subscriptions in the tenant
    except the ones listed here. This variable is mutually exclusive with
    `stream_subscription_ids`.
  EOT
  type        = list(string)
  default     = []
}

variable "enable_auto_discovery" {
  description = "Whether to enable auto-discovery of diagnostic settings."
  type        = bool
  default     = false
}

# endregion streaming_scope

# region general_configuration

variable "region" {
  description = <<-EOT
    The region where the integration resources will be created or the existing
    Event Hub.
  EOT
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the existing resource group for the Event Hub."
  type        = string
  default     = "upwindsecurity"
}

variable "resource_suffix" {
  description = "The suffix to append to all resources created by this module."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{0,10}$", var.resource_suffix))
    error_message = "The resource suffix must be alphanumeric and cannot exceed 10 characters."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# endregion general_configuration
