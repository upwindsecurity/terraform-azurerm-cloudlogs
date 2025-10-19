# Azure Policy rule definition for automatic deployment of diagnostic settings.
# This policy deploys diagnostic settings to stream Azure Logs from
# subscriptions to an Event Hub when the diagnostic setting doesn't exist.
locals {
  # Policy rule condition that can be overridden or use default field/value variables
  policy_rule_condition = (
    var.policy_rule_condition_override != null
    ? var.policy_rule_condition_override
    : (
        {
          field  = var.policy_rule_condition_field
          equals = var.policy_rule_condition_value
        }
      )
  )

  # Policy parameters definition for Event Hub configuration.
  policy_parameters = {
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
  }

  policy_rule = {
    if = local.policy_rule_condition
    then = {
      effect = "deployIfNotExists"
      details = {
        type            = "Microsoft.Insights/diagnosticSettings"
        deploymentScope = var.policy_deployment_scope
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
                      for category in var.diagnostic_setting_log_categories : {
                        category = category
                        enabled  = true
                      }
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
        roleDefinitionIds = local.all_role_definition_ids
      }
    }
  }
}
