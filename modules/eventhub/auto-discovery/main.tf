locals {
  root_management_group_id = "/providers/Microsoft.Management/managementGroups/${var.azure_tenant_id}"
}

provider "azurerm" {
  features {}
  tenant_id       = var.azure_tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_user_assigned_identity" "auto_discovery" {
  name                = "auto-discovery-identity"
  location            = "northeurope"
  resource_group_name = var.resource_group
}

resource "azurerm_policy_definition" "auto_discovery" {
  name                = "upwind-acitivity-logs-auto-discovery"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Upwind activity log auto-discovery"
  description         = "Deploys the diagnostic settings for Azure Activity to stream subscriptions activity logs to a Event hub"
  management_group_id = local.root_management_group_id

  metadata = jsonencode({
    category  = "Monitoring"
    createdBy = var.created_by
    createdOn = timestamp()
    updatedBy = null
    updatedOn = null
  })

  parameters = jsonencode({
    eventHubAuthRuleId = {
      type = "String"
      metadata = {
        displayName       = "Event Hub Authorization Rule ID"
        description       = "Resource ID of the Event Hub namespace authorization rule with Send claims."
        assignPermissions = true
      }
    }
    eventHubName = {
      type = "String"
      metadata = {
        displayName = "Event Hub Name"
        description = "Name of the Event Hub to which diagnostics will be sent."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Resources/subscriptions"
    }
    then = {
      effect = "deployIfNotExists"
      details = {
        type            = "Microsoft.Insights/diagnosticSettings"
        deploymentScope = "subscription"
        existenceScope  = "subscription"
        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId"
              equals = "[parameters('eventHubAuthRuleId')]"
            }
          ]
        }
        deployment = {
          location = var.region
          properties = {
            mode = "incremental"
            template = {
              "$schema"      = "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#"
              contentVersion = "1.0.0.0"
              parameters = {
                eventHubAuthRuleId = { type = "string" }
                eventHubName       = { type = "string" }
              }
              resources = [
                {
                  name       = var.diagnostic_settings_name
                  type       = "Microsoft.Insights/diagnosticSettings"
                  apiVersion = "2021-05-01-preview"
                  location   = "Global"
                  properties = {
                    eventHubAuthorizationRuleId = "[parameters('eventHubAuthRuleId')]"
                    eventHubName                = "[parameters('eventHubName')]"
                    logs = [
                      { category = "Administrative", enabled = true },
                      { category = "Security", enabled = true }
                    ]
                  }
                }
              ]
            }
            parameters = {
              eventHubAuthRuleId = { value = "[parameters('eventHubAuthRuleId')]" }
              eventHubName       = { value = "[parameters('eventHubName')]" }
            }
          }
        }
        roleDefinitionIds = local.role_defs
      }
    }
  })
}

locals {
  role_names = ["Contributor", "Monitoring Contributor"]
  role_defs  = [for role_name in local.role_names : data.azurerm_role_definition.this[role_name].id]
}

resource "azurerm_role_assignment" "auto_discovery" {
  for_each           = toset(local.role_defs)
  scope              = local.root_management_group_id
  role_definition_id = each.value
  principal_id       = azurerm_management_group_policy_assignment.auto_discovery.identity[0].principal_id
}

data "azurerm_role_definition" "this" {
  for_each = toset(local.role_names)
  name     = each.key
  scope    = local.root_management_group_id
}


resource "azurerm_management_group_policy_assignment" "auto_discovery" {
  name                 = "upwind-auto-discovery"
  display_name         = "upwind-auto-discovery"
  policy_definition_id = azurerm_policy_definition.auto_discovery.id
  management_group_id  = local.root_management_group_id
  parameters = jsonencode({
    eventHubAuthRuleId = { value = var.eventhub_authorization_rule_id }
    eventHubName       = { value = var.eventhub_name }
  })
  location = var.region
  identity {
    type = "SystemAssigned"
  }
}
