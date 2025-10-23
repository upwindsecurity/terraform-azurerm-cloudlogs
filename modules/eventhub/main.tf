# This module sets up Azure Monitor Logs monitoring with Upwind for
# monitoring and processing Azure activity and Entra ID logs. It creates and
# configures Event Hubs, diagnostic settings, service principals, and Key Vault
# resources to handle Azure log events.

# Local values for resource naming and configuration.
locals {
  # Conditional creation flags.
  conditional_create_eventhub       = !var.use_existing_eventhub
  conditional_create_resource_group = !var.use_existing_eventhub && !var.use_existing_resource_group

  # Resource group and region configuration.
  resource_group_name = (
    var.use_existing_eventhub || var.use_existing_resource_group
    ? data.azurerm_resource_group.existing[0].name
    : format("%s-%s", var.resource_group_name, var.resource_suffix)
  )
  region = (
    var.use_existing_eventhub || var.use_existing_resource_group
    ? data.azurerm_resource_group.existing[0].location
    : azurerm_resource_group.new[0].location
  )

  # Event Hub configuration.
  eventhub_name = (
    var.use_existing_eventhub
    ? data.azurerm_eventhub.existing[0].name
    : format("%s-%s", var.eventhub_name, var.resource_suffix)
  )
  eventhub_namespace_name = (
    var.use_existing_eventhub
    ? data.azurerm_eventhub_namespace.existing[0].name
    : format("%s-%s", var.eventhub_namespace_name, var.resource_suffix)
  )
  eventhub_namespace_id = (
    var.use_existing_eventhub
    ? data.azurerm_eventhub_namespace.existing[0].id
    : azurerm_eventhub_namespace.new[0].id
  )

  # Resource names with suffix applied.
  app_name = (
    format("%s-%s",
      var.application_name_prefix,
      var.resource_suffix,
    )
  )
  eventhub_consumer_group_name = (
    format("%s-%s",
      var.eventhub_consumer_group_name,
      var.resource_suffix,
    )
  )
  eventhub_authorization_rule_name = (
    format("%s-%s",
      var.eventhub_authorization_rule_name,
      var.resource_suffix,
    )
  )
  diagnostic_setting_name = (
    format("%s-%s",
      var.diagnostic_setting_name,
      var.resource_suffix,
    )
  )
  diagnostic_setting_entra_name = (
    format("%s-%s",
      var.diagnostic_setting_entra_name,
      var.resource_suffix,
    )
  )
  key_vault_name = (
    format("%s-%s",
      var.key_vault_name,
      var.resource_suffix,
    )
  )

  # Common tags for all Azure resources.
  common_tags = merge(
    {
      "ManagedBy"   = "terraform"
      "Application" = "upwind-azure-cloudlogs"
    },
    var.tags
  )

  # Auto-discovery module configuration
  auto_discovery_management_group_ids = (
    # If auto-discovery is disabled or using existing Event Hub, return an empty list
    !var.enable_auto_discovery || var.use_existing_eventhub
    ? toset([])

    # If streaming all subscriptions or selected subscriptions, return the tenant root management group ID
    : var.stream_all_subscriptions || length(var.stream_subscription_ids) > 0
    ? toset(
      ["/providers/Microsoft.Management/managementGroups/${var.tenant_id}"]
    )

    # Otherwise, return the list of management group IDs
    : toset(
      [for mg in data.azurerm_management_group.streaming :
      "/providers/Microsoft.Management/managementGroups/${mg.id}"]
    )
  )

  # Azure RBAC role definitions required for the integration.
  role_eventhub_data_receiver    = "Azure Event Hubs Data Receiver"
  role_monitoring_reader         = "Monitoring Reader"
  role_key_vault_secrets_officer = "Key Vault Secrets Officer"

  # Service principals that need Key Vault Secrets Officer access.
  key_vault_secrets_officer_principals = {
    "integration_sp" = azuread_service_principal.integration.object_id
    "onboarding_sp"  = data.azuread_service_principal.onboarding_sp.object_id
    "current_sp"     = data.azurerm_client_config.current_sp.object_id
  }

  # Extract subscription IDs from management groups.
  management_group_subscription_ids = flatten([
    for mg_key, mg in data.azurerm_management_group.streaming : [
      for sub_id in mg.subscription_ids : sub_id
    ]
  ])

  # Compute final subscription IDs based on streaming scope configuration.
  computed_subscription_ids = (
    # Mode 1: Specific subscriptions only.
    length(var.stream_subscription_ids) > 0
    ? toset(var.stream_subscription_ids)

    # Mode 2: Management groups with optional exclusions.
    : length(var.stream_management_group_ids) > 0
    ? setsubtract(
      toset(local.management_group_subscription_ids),
      toset(var.stream_exclude_subscription_ids)
    )

    # Mode 3: All subscriptions (explicit or implicit via exclusions).
    : var.stream_all_subscriptions || length(var.stream_exclude_subscription_ids) > 0
    ? setsubtract(
      toset([for sub in data.azurerm_subscriptions.all[0].subscriptions : sub.subscription_id]),
      toset(var.stream_exclude_subscription_ids)
    )

    # Mode 4: Default to infrastructure subscription.
    : toset([var.infrastructure_subscription_id])
  )

  # Key Vault secret configuration.
  key_vault_secret_content_type = "text/plain"
}

# Data source for existing resource group when using existing Event Hub or
# when a specific resource group is provided.
data "azurerm_resource_group" "existing" {
  count = var.use_existing_eventhub || var.use_existing_resource_group ? 1 : 0

  name = var.resource_group_name
}

# Create new resource group for Event Hub resources when not using existing
# Event Hub and no specific resource group is provided.
resource "azurerm_resource_group" "new" {
  count = local.conditional_create_resource_group ? 1 : 0

  name     = local.resource_group_name
  location = var.region
  tags     = local.common_tags
}

# Data source for existing Event Hub namespace when using existing Event Hub.
data "azurerm_eventhub_namespace" "existing" {
  count = var.use_existing_eventhub ? 1 : 0

  name                = var.eventhub_namespace_name
  resource_group_name = local.resource_group_name
}

# Create new Event Hub namespace when not using existing Event Hub.
resource "azurerm_eventhub_namespace" "new" {
  count = local.conditional_create_eventhub ? 1 : 0

  name                     = local.eventhub_namespace_name
  location                 = local.region
  resource_group_name      = local.resource_group_name
  sku                      = var.eventhub_pricing_tier
  auto_inflate_enabled     = var.eventhub_enable_auto_inflate
  maximum_throughput_units = var.eventhub_enable_auto_inflate ? var.eventhub_max_throughput_units : null
  tags                     = local.common_tags
}

# Data source for existing Event Hub when using existing Event Hub.
data "azurerm_eventhub" "existing" {
  count = var.use_existing_eventhub ? 1 : 0

  name                = var.eventhub_name
  namespace_name      = local.eventhub_namespace_name
  resource_group_name = local.resource_group_name
}

# Create new Event Hub for log streaming when not using existing Event Hub.
resource "azurerm_eventhub" "new" {
  count = local.conditional_create_eventhub ? 1 : 0

  name              = local.eventhub_name
  namespace_id      = local.eventhub_namespace_id
  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention_days
}

# Create consumer group for log processing (always created, references
# appropriate Event Hub).
resource "azurerm_eventhub_consumer_group" "integration" {
  name                = local.eventhub_consumer_group_name
  namespace_name      = local.eventhub_namespace_name
  eventhub_name       = local.eventhub_name
  resource_group_name = local.resource_group_name

  depends_on = [
    azurerm_eventhub.new,
    data.azurerm_eventhub.existing
  ]
}

# Create authorization rule for Event Hub namespace when not using existing
# Event Hub.
resource "azurerm_eventhub_namespace_authorization_rule" "new" {
  count = local.conditional_create_eventhub ? 1 : 0

  name                = local.eventhub_authorization_rule_name
  namespace_name      = local.eventhub_namespace_name
  resource_group_name = local.resource_group_name
  listen              = true
  send                = true
  manage              = false

  depends_on = [
    azurerm_eventhub.new,
    data.azurerm_eventhub.existing
  ]
}

# Azure AD application for integration.
resource "azuread_application" "integration" {
  display_name = local.app_name
  owners = coalescelist(
    var.application_owners,
    [data.azuread_client_config.current.object_id]
  )
  marketing_url = "https://www.upwind.io/"
  web {
    homepage_url = "https://www.upwind.io/"
  }
  # Long-lived password for the Azure AD application.
  password {
    end_date     = var.application_password_expiration_date
    display_name = "${local.app_name}_client_secret"
  }
}

# Service principal for the integration application.
resource "azuread_service_principal" "integration" {
  client_id = azuread_application.integration.client_id
  owners = coalescelist(
    var.application_owners,
    [data.azuread_client_config.current.object_id]
  )
}

# Role assignment for Event Hub data receiver access.
resource "azurerm_role_assignment" "eh_receiver" {
  scope                = local.eventhub_namespace_id
  role_definition_name = local.role_eventhub_data_receiver
  principal_id         = azuread_service_principal.integration.object_id
}

# Role assignment for monitoring reader access to subscription.
resource "azurerm_role_assignment" "monitoring_reader" {
  role_definition_name = local.role_monitoring_reader
  principal_id         = azuread_service_principal.integration.object_id
  scope                = data.azurerm_subscription.current.id # infrastructure
}

# Key Vault for storing integration service principal secrets.
resource "azurerm_key_vault" "integration" {
  name                      = local.key_vault_name
  location                  = local.region
  resource_group_name       = local.resource_group_name
  tenant_id                 = var.tenant_id
  sku_name                  = var.key_vault_sku_name
  purge_protection_enabled  = var.key_vault_purge_protection_enabled
  enable_rbac_authorization = var.key_vault_rbac_authorization_enabled
  tags                      = local.common_tags

  dynamic "network_acls" {
    for_each = var.key_vault_network_acls_enabled ? [1] : []
    content {
      default_action             = var.key_vault_network_acls_default_action
      bypass                     = var.key_vault_network_acls_bypass
      ip_rules                   = var.key_vault_network_acls_ip_rules
      virtual_network_subnet_ids = var.key_vault_network_acls_virtual_network_subnet_ids
    }
  }
}

# Role assignments for Key Vault secrets officer access.
resource "azurerm_role_assignment" "kv_secrets_officer" {
  for_each = local.key_vault_secrets_officer_principals

  role_definition_name = local.role_key_vault_secrets_officer
  principal_id         = each.value
  scope                = azurerm_key_vault.integration.id
}

# Key Vault secret for service principal client ID.
resource "azurerm_key_vault_secret" "sp_client_id" {
  name            = var.key_vault_client_id_secret_name
  value           = azuread_application.integration.client_id
  key_vault_id    = azurerm_key_vault.integration.id
  content_type    = local.key_vault_secret_content_type
  expiration_date = var.key_vault_secret_expiration_date
  tags            = local.common_tags

  depends_on = [
    azurerm_role_assignment.kv_secrets_officer
  ]
}

# Key Vault secret for service principal client secret.
resource "azurerm_key_vault_secret" "sp_client_secret" {
  name            = var.key_vault_client_secret_secret_name
  value           = [for p in azuread_application.integration.password : p.value][0]
  key_vault_id    = azurerm_key_vault.integration.id
  content_type    = local.key_vault_secret_content_type
  expiration_date = var.key_vault_secret_expiration_date
  tags            = local.common_tags

  depends_on = [
    azurerm_role_assignment.kv_secrets_officer
  ]
}

# Create diagnostic settings for activity logs to stream to Event Hub.
# Only created when not using existing Event Hub and subscription IDs are
# provided.
resource "azurerm_monitor_diagnostic_setting" "integration" {
  for_each = local.conditional_create_eventhub ? local.computed_subscription_ids : []

  name                           = local.diagnostic_setting_name
  target_resource_id             = "/subscriptions/${each.value}"
  eventhub_name                  = local.eventhub_name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.new[0].id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting_activity_log_categories
    content {
      category = enabled_log.value
    }
  }
}

# Create diagnostic settings for Entra ID logs to stream to Event Hub.
# Only created when enabled and not using existing Event Hub.
resource "azurerm_monitor_aad_diagnostic_setting" "integration" {
  count = local.conditional_create_eventhub && var.diagnostic_setting_enable_entra_logs ? 1 : 0

  name                           = local.diagnostic_setting_entra_name
  eventhub_name                  = local.eventhub_name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.new[0].id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting_entra_log_categories
    content {
      category = enabled_log.value
    }
  }
}

module "auto_discovery" {
  for_each                       = local.auto_discovery_management_group_ids
  source                         = "../auto-discovery"
  created_by                     = data.azuread_client_config.current.object_id
  diagnostic_settings_name       = local.diagnostic_setting_name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.new[0].id
  eventhub_name                  = local.eventhub_name
  region                         = local.region
  management_group_id            = each.value
  resource_suffix                = var.resource_suffix
}
