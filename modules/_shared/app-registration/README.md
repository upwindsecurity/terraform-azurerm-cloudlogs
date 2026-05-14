# app-registration (internal shared module)

> **Internal use only.** This module is not intended for direct consumption.
> It is called by [`modules/eventhub`](../../eventhub) and [`modules/aks-logs-reporter`](../../aks-logs-reporter).

Handles Azure AD application registration and service principal lifecycle for Upwind integrations. Encapsulates the three-scenario pattern used across integration modules.

## Scenarios

| Scenario | Condition | Behavior |
|---|---|---|
| **Create new** | `azure_application_client_id = null` | Creates a new `azuread_application` + `azuread_service_principal` |
| **Use existing (lookup)** | `azure_application_client_id` set, `azure_application_service_principal_object_id = null` | Looks up the service principal via `data "azuread_service_principal"` |
| **Use existing (explicit)** | Both `azure_application_client_id` and `azure_application_service_principal_object_id` set | Uses provided values directly; no data source lookup |

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `application_name_prefix` | `string` | — | Base name prefix. Combined with `resource_suffix` to form the display name. |
| `resource_suffix` | `string` | — | Suffix appended to the application name for uniqueness. |
| `application_password_expiration_date` | `string` | — | Client secret expiration date (RFC3339). |
| `application_owners` | `list(string)` | `[]` | Azure AD object IDs to set as application owners. Defaults to current caller. |
| `azure_application_client_id` | `string` | `null` | Client ID of an existing application. If set, skips resource creation. |
| `azure_application_client_secret` | `string` | `null` | Client secret of the existing application. Required when `azure_application_client_id` is set. |
| `azure_application_service_principal_object_id` | `string` | `null` | Object ID of the existing service principal. If set, skips the data source lookup. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `client_id` | no | Client ID of the Azure AD application (new or existing). |
| `client_secret` | yes | Client secret of the application. `null` when using existing application without a provided secret. |
| `service_principal_object_id` | no | Object ID of the service principal (new or existing). |
