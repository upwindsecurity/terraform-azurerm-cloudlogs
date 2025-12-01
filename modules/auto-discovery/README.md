<!-- BEGIN_TF_DOCS -->
# Auto-Discovery Module

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.54.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group_policy_assignment.policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_policy_definition.policy_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_role_assignment.policy_builtin_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.policy_custom_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom_diagnostics_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.built_in_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_built_in_role_names"></a> [built\_in\_role\_names](#input\_built\_in\_role\_names) | List of Azure RBAC role names that will be assigned to the policy assignment<br/>managed identity for deploying diagnostic settings across subscriptions. | `list(string)` | <pre>[<br/>  "Monitoring Contributor"<br/>]</pre> | no |
| <a name="input_created_by"></a> [created\_by](#input\_created\_by) | Object ID of the principal creating the resources. This is used for<br/>metadata tracking and should be the object ID of the user or service<br/>principal deploying the auto-discovery policy. | `string` | n/a | yes |
| <a name="input_custom_role_actions"></a> [custom\_role\_actions](#input\_custom\_role\_actions) | List of Azure actions that the custom role will have permissions to perform.<br/>These actions are required for diagnostic settings management and Event Hub<br/>authorization rule operations. | `list(string)` | <pre>[<br/>  "Microsoft.Insights/diagnosticSettings/*",<br/>  "Microsoft.EventHub/namespaces/authorizationRules/listKeys/*",<br/>  "Microsoft.Resources/deployments/*"<br/>]</pre> | no |
| <a name="input_custom_role_name"></a> [custom\_role\_name](#input\_custom\_role\_name) | Name for the custom RBAC role definition that will be created to provide<br/>specific permissions for diagnostic settings and Event Hub operations. | `string` | `"Upwind CloudLogs Diagnostics Role"` | no |
| <a name="input_diagnostic_setting_log_categories"></a> [diagnostic\_setting\_log\_categories](#input\_diagnostic\_setting\_log\_categories) | List of log categories to enable in the diagnostic setting.<br/>Currently, only `Administrative` and `Security` categories are<br/>supported by Upwind. Do not modify unless instructed by Upwind support. | `list(string)` | <pre>[<br/>  "Administrative",<br/>  "Security"<br/>]</pre> | no |
| <a name="input_diagnostic_settings_name"></a> [diagnostic\_settings\_name](#input\_diagnostic\_settings\_name) | Name for the diagnostic settings resource that will be automatically<br/>created by the policy across subscriptions. | `string` | `"upwindsecurity"` | no |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | Resource ID of the Event Hub namespace authorization rule with Send claims.<br/>This should be the authorization rule ID from the parent Event Hub module. | `string` | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Name of the Event Hub to send diagnostics to. This should match the<br/>Event Hub created by the parent module. | `string` | n/a | yes |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | Management group ID where the auto-discovery policy will be deployed. Can be the root tenant management group ID or a specific management group ID.<br/>Should be in the format: /providers/Microsoft.Management/managementGroups/{mg-name} | `string` | n/a | yes |
| <a name="input_policy_category"></a> [policy\_category](#input\_policy\_category) | Category for the Azure Policy definition. This is used for organizational<br/>purposes in the Azure portal to group related policies together. | `string` | `"Upwind Policies"` | no |
| <a name="input_policy_deployment_scope"></a> [policy\_deployment\_scope](#input\_policy\_deployment\_scope) | Deployment scope for the Azure Policy assignment. This can be either<br/>"subscription" or "resourceGroup". | `string` | `"subscription"` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description for the Azure Policy definition that explains its purpose<br/>and functionality. | `string` | `"Deploys the diagnostic settings to stream logs to an Event Hub that connected to Upwind logs intgration"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name for the Azure Policy definition. This will be used for both the<br/>policy name and display name. | `string` | `"upwind-logs"` | no |
| <a name="input_policy_rule_condition_field"></a> [policy\_rule\_condition\_field](#input\_policy\_rule\_condition\_field) | Field for the Azure Policy rule. The policy will evaluate such field with existence condition | `string` | `"type"` | no |
| <a name="input_policy_rule_condition_override"></a> [policy\_rule\_condition\_override](#input\_policy\_rule\_condition\_override) | Optional JSON object to completely override the policy rule condition.<br/>If provided, this will replace the entire 'if' block in the policy rule.<br/>When null, the default condition will be built using policy\_rule\_condition\_field<br/>and policy\_rule\_condition\_value variables. | `object({})` | `null` | no |
| <a name="input_policy_rule_condition_value"></a> [policy\_rule\_condition\_value](#input\_policy\_rule\_condition\_value) | Resource type for the Azure Policy rule.<br/>The policy will evaluate resource met `policy_rule_condition_field` == `policy_rule_condition_value` with existence the condition | `string` | `"Microsoft.Resources/subscriptions"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region for resource deployment. This should match the region<br/>where the Event Hub infrastructure is deployed. | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | The suffix to append to all resources created by this module. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_definition_id"></a> [custom\_role\_definition\_id](#output\_custom\_role\_definition\_id) | The ID of the custom RBAC role definition created for auto-discovery operations.<br/>This role provides specific permissions for diagnostic settings and Event Hub<br/>authorization rule operations. |
| <a name="output_custom_role_definition_name"></a> [custom\_role\_definition\_name](#output\_custom\_role\_definition\_name) | The name of the custom RBAC role definition for auto-discovery.<br/>This is the human-readable name of the role as it appears in Azure Portal. |
| <a name="output_management_group_id"></a> [management\_group\_id](#output\_management\_group\_id) | The management group ID where the auto-discovery policy is deployed.<br/>This shows the scope where the policy will enforce diagnostic settings<br/>creation across all child subscriptions. |
| <a name="output_management_group_name"></a> [management\_group\_name](#output\_management\_group\_name) | The extracted management group name from the full resource ID.<br/>This is used for resource naming and identification purposes. |
| <a name="output_policy_assignment_id"></a> [policy\_assignment\_id](#output\_policy\_assignment\_id) | The ID of the Azure Policy assignment for auto-discovery.<br/>This represents the active policy enforcement on the management group. |
| <a name="output_policy_assignment_identity_principal_id"></a> [policy\_assignment\_identity\_principal\_id](#output\_policy\_assignment\_identity\_principal\_id) | The principal ID of the system-assigned managed identity created for<br/>the policy assignment. This identity is used to deploy diagnostic<br/>settings across subscriptions within the management group. |
| <a name="output_policy_assignment_name"></a> [policy\_assignment\_name](#output\_policy\_assignment\_name) | The name of the Azure Policy assignment for auto-discovery.<br/>This is the assignment instance name within the management group scope. |
| <a name="output_policy_definition_id"></a> [policy\_definition\_id](#output\_policy\_definition\_id) | The ID of the Azure Policy definition for auto-discovery of diagnostic settings.<br/>This can be used to reference the policy in other Terraform configurations<br/>or for policy compliance reporting. |
| <a name="output_policy_definition_name"></a> [policy\_definition\_name](#output\_policy\_definition\_name) | The name of the Azure Policy definition for auto-discovery.<br/>This is the human-readable identifier used in Azure Portal. |
| <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments) | Summary information about the role assignments created for the policy<br/>assignment's managed identity. This includes both built-in and custom<br/>role assignments that grant necessary permissions for auto-discovery operations. |
<!-- END_TF_DOCS -->
