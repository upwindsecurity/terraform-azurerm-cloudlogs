# region azure_integration_scope

variable "tenant_id" {
  description = "The Azure Tenant that will be onboarded to the Upwind Azure Monitor Logs monitoring."
  type        = string
}

variable "infrastructure_subscription_id" {
  description = <<-EOT
    The subscription ID where the infrastructure resources (Event Hub, Key
    Vault, Service Principal, etc.) will be deployed or already exist. This
    must match the subscription context of your authenticated Azure provider.
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
    The client ID of the Upwind onboarding service principal. This service
    principal will be granted Key Vault Secrets Officer access to manage
    the integration service principal secrets.
  EOT
  type        = string
}

# endregion azure_integration_scope

# region azure_ad_application

variable "application_name_prefix" {
  description = "The Upwind AD application display name prefix."
  type        = string
  default     = "upwindsecurity-cloudlogs"
}

variable "application_owners" {
  description = <<-EOT
    List of user IDs that will be set as owners of the Azure application &
    service principal. Each ID should be in the form of a GUID. If this list
    is left empty, the owner defaults to the authenticated principal.
  EOT
  type        = list(string)
  default     = []
}

variable "application_password_expiration_date" {
  description = <<-EOT
    The expiration date for the Azure AD application password in RFC3339 format
    (e.g., `2999-12-31T23:59:59Z`). This determines when the application
    password expires.
  EOT
  type        = string
  default     = "2999-12-31T23:59:59Z"

  validation {
    condition     = can(timecmp(var.application_password_expiration_date, "1970-01-01T00:00:00Z"))
    error_message = "The expiration date must be in RFC3339 format (e.g., `2999-12-31T23:59:59Z`)."
  }
}

variable "azure_application_client_id" {
  description = "Optional client ID of an existing Azure AD application. If provided, the module will use this existing application instead of creating a new one. Mutually exclusive with application_name_prefix."
  type        = string
  default     = null

  validation {
    condition     = var.azure_application_client_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.azure_application_client_id))
    error_message = "The azure_application_client_id must be a valid GUID format."
  }
}

variable "azure_application_client_secret" {
  description = "Client secret for the existing Azure AD application. Required when azure_application_client_id is provided and organizational credentials will be created. Should be managed externally (e.g., Azure Portal, CLI, or separate automation)."
  type        = string
  default     = null
  sensitive   = true
}

variable "azure_application_service_principal_object_id" {
  description = "The service principal object ID of the existing Azure AD application. Optional, if provided the module will skip looking up the service principal object ID. Should be managed externally (e.g., Azure Portal, CLI, or separate automation)."
  type        = string
  default     = null

  validation {
    condition     = var.azure_application_service_principal_object_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.azure_application_service_principal_object_id))
    error_message = "The azure_application_service_principal_object_id must be a valid GUID format."
  }
}

# endregion azure_ad_application

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

# region key_vault

variable "key_vault_name" {
  description = <<-EOT
    The name of the Key Vault used to store integration service principal
    secrets and credentials.
  EOT
  type        = string
  default     = "upwindsecurity"
}

variable "key_vault_sku_name" {
  description = "The SKU name of the Key Vault."
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection_enabled" {
  description = "Whether to enable purge protection for the Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_rbac_authorization_enabled" {
  description = "Whether to enable RBAC authorization for the Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_client_id_secret_name" {
  description = "The name of the Key Vault secret for service principal client ID."
  type        = string
  default     = "sp-client-id"
}

variable "key_vault_client_secret_secret_name" {
  description = <<-EOT
    The name of the Key Vault secret for service principal client secret.
  EOT
  type        = string
  default     = "sp-client-secret"
}

variable "key_vault_network_acls_enabled" {
  description = <<-EOT
    Whether to enable network ACLs for the Key Vault. When enabled, network
    access rules will be applied based on the other network ACL variables.
  EOT
  type        = bool
  default     = false
}

variable "key_vault_network_acls_default_action" {
  description = <<-EOT
    The default action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`.
    Possible values are `Allow` and `Deny`. Only used when `key_vault_network_acls_enabled` is `true`.
  EOT
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_acls_default_action)
    error_message = "The default action must be either `Allow` or `Deny`."
  }
}

variable "key_vault_network_acls_bypass" {
  description = <<-EOT
    Specifies which traffic can bypass the network rules. Possible values are
    `AzureServices` and `None`. Only used when `key_vault_network_acls_enabled` is `true`.
  EOT
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_network_acls_bypass)
    error_message = "The bypass value must be either `AzureServices` or `None`."
  }
}

variable "key_vault_network_acls_ip_rules" {
  description = <<-EOT
    One or more IP addresses or CIDR blocks which should be able to access
    the Key Vault. Only used when `key_vault_network_acls_enabled` is `true`.
  EOT
  type        = list(string)
  default     = []
}

variable "key_vault_network_acls_virtual_network_subnet_ids" {
  description = <<-EOT
    One or more subnet IDs which should be able to access this Key Vault.
    Only used when `key_vault_network_acls_enabled` is `true`.
  EOT
  type        = list(string)
  default     = []
}

variable "key_vault_secret_expiration_date" {
  description = <<-EOT
    The expiration date for the Key Vault secrets in RFC3339 format
    (e.g., `2025-12-31T23:59:59Z`). If not specified, secrets will not expire.
  EOT
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_secret_expiration_date == null ||
      can(timecmp(var.key_vault_secret_expiration_date, "1970-01-01T00:00:00Z"))
    )
    error_message = "The expiration date must be in RFC3339 format (e.g., `2025-12-31T23:59:59Z`) or null."
  }
}

# endregion key_vault

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
