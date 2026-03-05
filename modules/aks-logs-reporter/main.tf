# This module sets up Event Hub infrastructure for receiving AKS Kubernetes
# audit logs. It creates one Event Hub stack per Azure region (auto-detected
# from aks_cluster_ids or explicitly listed in regions), a shared Service
# Principal, and a single Key Vault in infrastructure_region.
# Optionally creates AKS diagnostic settings to stream logs into the Event Hubs.

# Local values for resource naming and configuration.
locals {
  # Derive the set of regions from AKS cluster locations plus explicit regions.
  detected_regions = toset([
    for _, c in data.azurerm_kubernetes_cluster.clusters : c.location
  ])
  all_regions = toset(concat(tolist(local.detected_regions), var.regions))

  # Resource names with suffix applied.
  app_name = format("%s-%s",
    var.application_name_prefix,
    var.resource_suffix,
  )
  eventhub_consumer_group_name = (
    var.resource_suffix != ""
    ? "${var.eventhub_consumer_group_name}-${var.resource_suffix}"
    : var.eventhub_consumer_group_name
  )
  diagnostic_setting_name = (
    var.resource_suffix != ""
    ? "${var.diagnostic_setting_name}-${var.resource_suffix}"
    : var.diagnostic_setting_name
  )
  key_vault_name = format("%s-%s",
    var.key_vault_name,
    var.resource_suffix,
  )

  # Common tags for all Azure resources.
  common_tags = merge(
    {
      "ManagedBy"       = "terraform"
      "Application"     = "upwind-aks-audit-logs"
      "UpwindComponent" = "CloudLogReporter"
    },
    var.tags
  )

  # Azure RBAC role definitions required for the integration.
  role_eventhub_data_receiver    = "Azure Event Hubs Data Receiver"
  role_monitoring_reader         = "Monitoring Reader"
  role_key_vault_secrets_officer = "Key Vault Secrets Officer"
  role_key_vault_secret_user     = "Key Vault Secrets User"

  # Key Vault secret configuration.
  key_vault_secret_content_type = "text/plain"

  # Effective region for Key Vault and shared resources.
  effective_key_vault_region = coalesce(var.key_vault_region, var.infrastructure_region)

  # Event Hub connection details per region — used by outputs and the
  # optional diagnostic settings resources.
  eventhub_by_region = {
    for region in local.all_regions : region => {
      eventhub_name                  = azurerm_eventhub.regions[region].name
      eventhub_namespace_name        = azurerm_eventhub_namespace.regions[region].name
      resource_group_name            = azurerm_resource_group.regions[region].name
      eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.regions[region].id
    }
  }

  # AKS clusters for which diagnostic settings will be created.
  diagnostic_setting_cluster_ids = (
    var.create_diagnostic_settings && length(var.aks_cluster_ids) > 0
    ? toset(var.aks_cluster_ids)
    : toset([])
  )

  # Parse each cluster ID into { name, resource_group_name } for data source lookup.
  # ARM ID format: /subscriptions/[2]/resourceGroups/[4]/providers/Microsoft.ContainerService/managedClusters/[8]
  aks_cluster_refs = {
    for id in var.aks_cluster_ids : id => {
      name                = split("/", id)[8] # segment 8 = cluster name
      resource_group_name = split("/", id)[4] # segment 4 = resource group name
    }
  }
}

module "app_registration" {
  source = "../_shared/app-registration"

  application_name_prefix                       = var.application_name_prefix
  resource_suffix                               = var.resource_suffix
  application_password_expiration_date          = var.application_password_expiration_date
  application_owners                            = var.application_owners
  azure_application_client_id                   = var.azure_application_client_id
  azure_application_client_secret               = var.azure_application_client_secret
  azure_application_service_principal_object_id = var.azure_application_service_principal_object_id
}

# Shared resource group for Key Vault and global resources.
resource "azurerm_resource_group" "shared" {
  name     = "${var.resource_group_name}-shared-${var.resource_suffix}"
  location = local.effective_key_vault_region
  tags     = local.common_tags

  lifecycle {
    precondition {
      condition     = length(local.all_regions) > 0
      error_message = "At least one of `aks_cluster_ids` or `regions` must be non-empty."
    }
  }
}

# Per-region resource groups.
resource "azurerm_resource_group" "regions" {
  for_each = local.all_regions

  name     = "${var.resource_group_name}-${each.key}-${var.resource_suffix}"
  location = each.key
  tags     = local.common_tags
}

# Per-region Event Hub namespaces.
resource "azurerm_eventhub_namespace" "regions" {
  for_each = local.all_regions

  name                     = "${var.eventhub_namespace_name}-${each.key}-${var.resource_suffix}"
  location                 = each.key
  resource_group_name      = azurerm_resource_group.regions[each.key].name
  sku                      = var.eventhub_pricing_tier
  auto_inflate_enabled     = var.eventhub_enable_auto_inflate
  maximum_throughput_units = var.eventhub_enable_auto_inflate ? var.eventhub_max_throughput_units : null
  tags                     = local.common_tags
}

# Per-region Event Hubs.
resource "azurerm_eventhub" "regions" {
  for_each = local.all_regions

  name              = "${var.eventhub_name}-${each.key}-${var.resource_suffix}"
  namespace_id      = azurerm_eventhub_namespace.regions[each.key].id
  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention_days
}

# Per-region consumer groups for log processing.
resource "azurerm_eventhub_consumer_group" "regions" {
  for_each = local.all_regions

  name                = local.eventhub_consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.regions[each.key].name
  eventhub_name       = azurerm_eventhub.regions[each.key].name
  resource_group_name = azurerm_resource_group.regions[each.key].name
}

# Per-region authorization rules.
resource "azurerm_eventhub_namespace_authorization_rule" "regions" {
  for_each = local.all_regions

  name                = "${var.eventhub_authorization_rule_name}-${each.key}-${var.resource_suffix}"
  namespace_name      = azurerm_eventhub_namespace.regions[each.key].name
  resource_group_name = azurerm_resource_group.regions[each.key].name
  listen              = true
  send                = true
  manage              = false

  depends_on = [azurerm_eventhub.regions]
}

# Role assignment for Event Hub data receiver access on every regional namespace.
resource "azurerm_role_assignment" "eh_receiver" {
  for_each = azurerm_eventhub_namespace.regions

  role_definition_name = local.role_eventhub_data_receiver
  principal_id         = module.app_registration.service_principal_object_id
  scope                = each.value.id
}

# Role assignment for monitoring reader access to subscription.
resource "azurerm_role_assignment" "monitoring_reader" {
  role_definition_name = local.role_monitoring_reader
  principal_id         = module.app_registration.service_principal_object_id
  scope                = data.azurerm_subscription.current.id
}

# Key Vault for storing integration service principal secrets.
resource "azurerm_key_vault" "integration" {
  name                       = local.key_vault_name
  location                   = local.effective_key_vault_region
  resource_group_name        = azurerm_resource_group.shared.name
  tenant_id                  = var.tenant_id
  sku_name                   = var.key_vault_sku_name
  purge_protection_enabled   = var.key_vault_purge_protection_enabled
  rbac_authorization_enabled = var.key_vault_rbac_authorization_enabled
  tags                       = local.common_tags

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

# Role assignment for Key Vault secrets officer access for current service principal.
resource "azurerm_role_assignment" "kv_secrets_officer" {
  role_definition_name = local.role_key_vault_secrets_officer
  principal_id         = data.azurerm_client_config.current_sp.object_id
  scope                = azurerm_key_vault.integration.id
}

# Role assignment for Key Vault secrets user access for onboarding service principal.
resource "azurerm_role_assignment" "kv_secrets_user" {
  role_definition_name = local.role_key_vault_secret_user
  principal_id         = data.azuread_service_principal.onboarding_sp.object_id
  scope                = azurerm_key_vault.integration.id
}

# Key Vault secret for service principal client ID.
resource "azurerm_key_vault_secret" "sp_client_id" {
  name            = var.key_vault_client_id_secret_name
  value           = module.app_registration.client_id
  key_vault_id    = azurerm_key_vault.integration.id
  content_type    = local.key_vault_secret_content_type
  expiration_date = var.key_vault_secret_expiration_date
  tags            = local.common_tags

  depends_on = [
    azurerm_role_assignment.kv_secrets_officer,
    azurerm_role_assignment.kv_secrets_user,
  ]
}

# Key Vault secret for service principal client secret.
resource "azurerm_key_vault_secret" "sp_client_secret" {
  name = var.key_vault_client_secret_secret_name
  value = module.app_registration.client_secret
  key_vault_id    = azurerm_key_vault.integration.id
  content_type    = local.key_vault_secret_content_type
  expiration_date = var.key_vault_secret_expiration_date
  tags            = local.common_tags

  depends_on = [
    azurerm_role_assignment.kv_secrets_officer,
    azurerm_role_assignment.kv_secrets_user,
  ]

  lifecycle {
    precondition {
      condition     = var.azure_application_client_id == null || var.azure_application_client_secret != null
      error_message = "`azure_application_client_secret` must be provided when `azure_application_client_id` is set."
    }
  }
}

# Warn when create_diagnostic_settings is true but no cluster IDs were provided,
# which would silently result in no diagnostic settings being created.
check "diagnostic_settings_require_cluster_ids" {
  assert {
    condition     = !var.create_diagnostic_settings || length(var.aks_cluster_ids) > 0
    error_message = "`create_diagnostic_settings` is true but `aks_cluster_ids` is empty — no diagnostic settings will be created."
  }
}

# Diagnostic settings for each AKS cluster, routing logs to the Event Hub in
# the same region as the cluster. Only created when create_diagnostic_settings
# is true and aks_cluster_ids is non-empty.
resource "azurerm_monitor_diagnostic_setting" "aks" {
  for_each = local.diagnostic_setting_cluster_ids

  name               = local.diagnostic_setting_name
  target_resource_id = each.value

  eventhub_name = local.eventhub_by_region[
    data.azurerm_kubernetes_cluster.clusters[each.value].location
  ].eventhub_name

  eventhub_authorization_rule_id = local.eventhub_by_region[
    data.azurerm_kubernetes_cluster.clusters[each.value].location
  ].eventhub_authorization_rule_id

  dynamic "enabled_log" {
    for_each = var.log_categories
    content {
      category = enabled_log.value
    }
  }
}
