
variable "management_group_id" {
  description = <<-EOT
    Management group ID where the auto-discovery policy will be deployed.
    Should be in the format: /providers/Microsoft.Management/managementGroups/{mg-name}
  EOT
  type        = string
}

variable "created_by" {
  description = <<-EOT
    Object ID of the principal creating the resources. This is used for
    metadata tracking and should be the object ID of the user or service
    principal deploying the auto-discovery policy.
  EOT
  type        = string
}

variable "region" {
  description = <<-EOT
    Azure region for resource deployment. This should match the region
    where the Event Hub infrastructure is deployed.
  EOT
  type        = string
}


variable "diagnostic_settings_name" {
  description = <<-EOT
    Name for the diagnostic settings resource that will be automatically
    created by the policy across subscriptions.
  EOT
  type        = string
  default     = "upwind-activity-logs-auto-discovery"
}


variable "eventhub_name" {
  description = <<-EOT
    Name of the Event Hub to send diagnostics to. This should match the
    Event Hub created by the parent module.
  EOT
  type        = string
}

variable "eventhub_authorization_rule_id" {
  description = <<-EOT
    Resource ID of the Event Hub namespace authorization rule with Send claims.
    This should be the authorization rule ID from the parent Event Hub module.
  EOT
  type        = string
}

variable "built_in_role_names" {
  description = <<-EOT
    List of Azure RBAC role names that will be assigned to the policy assignment
    managed identity for deploying diagnostic settings across subscriptions.
  EOT
  type        = list(string)
  default = [
    "Monitoring Contributor"
  ]
}

variable "diagnostic_setting_log_categories" {
  description = <<-EOT
    List of log categories to enable in the diagnostic setting.
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
      for category in var.diagnostic_setting_log_categories :
      contains(["Administrative", "Security"], category)
    ])
    error_message = <<-EOT
      Only `Administrative` and `Security` log categories are currently supported by Upwind.
    EOT
  }
}

variable "policy_name" {
  description = <<-EOT
    Name for the Azure Policy definition. This will be used for both the
    policy name and display name.
  EOT
  type        = string
  default     = "upwind-logs"
}

variable "policy_description" {
  description = <<-EOT
    Description for the Azure Policy definition that explains its purpose
    and functionality.
  EOT
  type        = string
  default     = "Deploys the diagnostic settings to stream logs to an Event Hub that connected to Upwind logs intgration"
}


variable "policy_category" {
  description = <<-EOT
    Category for the Azure Policy definition. This is used for organizational
    purposes in the Azure portal to group related policies together.
  EOT
  type        = string
  default     = "Upwind Policies"
}

variable "policy_deployment_scope" {
  description = <<-EOT
    Deployment scope for the Azure Policy assignment. This can be either
    "subscription" or "resourceGroup".
  EOT
  type        = string
  default     = "subscription"
}

variable "custom_role_name" {
  description = <<-EOT
    Name for the custom RBAC role definition that will be created to provide
    specific permissions for diagnostic settings and Event Hub operations.
  EOT
  type        = string
  default     = "Upwind CloudLogs Diagnostics Role"
}

variable "custom_role_actions" {
  description = <<-EOT
    List of Azure actions that the custom role will have permissions to perform.
    These actions are required for diagnostic settings management and Event Hub
    authorization rule operations.
  EOT
  type        = list(string)
  default = [
    "Microsoft.Insights/diagnosticSettings/*",
    "Microsoft.EventHub/namespaces/authorizationRules/listKeys/*",
    "Microsoft.Resources/deployments/*"
  ]
}

variable "policy_rule_condition_field" {
  description = <<-EOT
    Field for the Azure Policy rule. The policy will evaluate such field with existence condition
  EOT
  type        = string
  default     = "type"
}

variable "policy_rule_condition_value" {
  description = <<-EOT
    Resource type for the Azure Policy rule.
    The policy will evaluate resource met `policy_rule_condition_field` == `policy_rule_condition_value` with existence the condition
  EOT
  type        = string
  default     = "Microsoft.Resources/subscriptions"
}

variable "policy_rule_condition_override" {
  description = <<-EOT
    Optional JSON object to completely override the policy rule condition.
    If provided, this will replace the entire 'if' block in the policy rule.
    When null, the default condition will be built using policy_rule_condition_field
    and policy_rule_condition_value variables.
  EOT
  type        = object({})
  default     = null
}

variable "resource_suffix" {
  description = "The suffix to append to all resources created by this module."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{0,10}$", var.resource_suffix))
    error_message = "The resource suffix must be alphanumeric and cannot exceed 10 characters."
  }
}
