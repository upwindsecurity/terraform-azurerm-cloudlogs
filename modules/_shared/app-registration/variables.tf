variable "application_name_prefix" {
  description = "Base name prefix for the Azure AD application. Combined with `resource_suffix` to form the full name."
  type        = string
}

variable "resource_suffix" {
  description = "Suffix appended to the application name to ensure uniqueness."
  type        = string
}

variable "application_password_expiration_date" {
  description = "Expiration date for the generated client secret, in RFC3339 format."
  type        = string
}

variable "application_owners" {
  description = "List of Azure AD object IDs to set as owners of the application. Defaults to the current caller if empty."
  type        = list(string)
  default     = []
}

variable "azure_application_client_id" {
  description = "Client ID of an existing Azure AD application. If set, no new application is created."
  type        = string
  default     = null
}

variable "azure_application_client_secret" {
  description = "Client secret of the existing Azure AD application. Required when `azure_application_client_id` is set."
  type        = string
  default     = null
  sensitive   = true
}

variable "azure_application_service_principal_object_id" {
  description = "Object ID of the existing service principal. If set alongside `azure_application_client_id`, skips the service principal data source lookup."
  type        = string
  default     = null
}
