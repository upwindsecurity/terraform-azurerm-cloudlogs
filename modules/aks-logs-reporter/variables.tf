# region azure_integration_scope

variable "tenant_id" {
  description = "The Azure Tenant that will be onboarded to Upwind for AKS audit logs monitoring."
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
    principal will be granted Key Vault Secrets User access to read
    the integration service principal secrets.
  EOT
  type        = string
}

# endregion azure_integration_scope

# region azure_ad_application

variable "application_name_prefix" {
  description = "The Upwind AD application display name prefix."
  type        = string
  default     = "upwindsecurity-aks-logs"
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
  description = "Optional client ID of an existing Azure AD application. If provided, the module will use this existing application instead of creating a new one."
  type        = string
  default     = null

  validation {
    condition     = var.azure_application_client_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.azure_application_client_id))
    error_message = "The azure_application_client_id must be a valid GUID format."
  }
}

variable "azure_application_client_secret" {
  description = "Client secret for the existing Azure AD application. Required when azure_application_client_id is provided."
  type        = string
  default     = null
  sensitive   = true
}

variable "azure_application_service_principal_object_id" {
  description = "The service principal object ID of the existing Azure AD application. Optional — if provided the module will skip looking up the service principal object ID."
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
  description = "The name prefix for the Event Hub. The region and resource suffix will be appended."
  type        = string
  default     = "upwindsecurity-aks"
}

variable "eventhub_namespace_name" {
  description = "The name prefix for the Event Hub namespace. The region and resource suffix will be appended."
  type        = string
  default     = "upwindsecurity-aks"
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
  description = "The maximum number of throughput units when auto-inflate is enabled."
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
  description = "The name prefix for the consumer group to be created."
  type        = string
  default     = "upwindsecurity-aks"
}

variable "eventhub_authorization_rule_name" {
  description = "The name prefix for the authorization rule to be created. The region and resource suffix will be appended."
  type        = string
  default     = "upwindsecurity-aks"
}

# endregion eventhub_configuration

# region key_vault

variable "key_vault_name" {
  description = <<-EOT
    The name of the Key Vault used to store integration service principal
    secrets and credentials.
  EOT
  type        = string
  default     = "upwindsecurity-aks"
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
  description = "The name of the Key Vault secret for service principal client secret."
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

variable "aks_cluster_ids" {
  description = <<-EOT
    List of AKS cluster resource IDs used to auto-detect the Azure regions
    where Event Hub infrastructure should be deployed. The module reads each
    cluster's location and creates one Event Hub stack per unique region.
    Requires read access to the AKS clusters via the configured provider.
    At least one of `aks_cluster_ids` or `regions` must be non-empty.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.aks_cluster_ids :
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.ContainerService/managedClusters/[^/]+$", id))
    ])
    error_message = <<-EOT
      Each AKS cluster ID must be in the format:
      /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.ContainerService/managedClusters/{cluster-name}
    EOT
  }
}

variable "regions" {
  description = <<-EOT
    Explicit list of Azure regions in which to create Event Hub infrastructure.
    Used when cross-subscription AKS data-source access is unavailable, or to
    add extra regions beyond those auto-detected from `aks_cluster_ids`.
    At least one of `aks_cluster_ids` or `regions` must be non-empty.
  EOT
  type        = list(string)
  default     = []
}

variable "infrastructure_region" {
  description = <<-EOT
    The Azure region where all global/shared resources are created (Key Vault,
    shared resource group, etc.).
  EOT
  type        = string
}

variable "key_vault_region" {
  description = <<-EOT
    The Azure region where the Key Vault and its resource group will be created.
    Defaults to `infrastructure_region` when not set.
  EOT
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name prefix for resource groups created by this module. The region and resource suffix will be appended."
  type        = string
  default     = "upwindsecurity-aks"
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

# region diagnostic_settings

variable "create_diagnostic_settings" {
  description = <<-EOT
    Whether to automatically create AKS diagnostic settings to stream logs to
    the Event Hub. When true, requires `aks_cluster_ids` to be non-empty.
    Set to false if you only want the Event Hub infrastructure without
    configuring AKS clusters.
  EOT
  type        = bool
  default     = true
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting to be created on each AKS cluster."
  type        = string
  default     = "upwind-aks-audit"
}

variable "log_categories" {
  description = <<-EOT
    List of log categories to enable for AKS diagnostic settings.
    Common categories: kube-audit, kube-audit-admin, kube-apiserver,
    kube-controller-manager, kube-scheduler, cluster-autoscaler.
  EOT
  type        = list(string)
  default     = ["kube-audit"]

  validation {
    condition     = length(var.log_categories) > 0
    error_message = "At least one log category must be specified."
  }
}

# endregion diagnostic_settings
