locals {
  create_application = var.azure_application_client_id == null

  app_name = format("%s-%s", var.application_name_prefix, var.resource_suffix)

  client_id = (
    local.create_application
    ? azuread_application.integration[0].client_id
    : var.azure_application_client_id
  )

  client_secret = (
    local.create_application
    ? [for p in azuread_application.integration[0].password : p.value][0]
    : var.azure_application_client_secret
  )

  service_principal_object_id = (
    local.create_application
    ? azuread_service_principal.integration[0].object_id
    : var.azure_application_service_principal_object_id != null
    ? var.azure_application_service_principal_object_id
    : data.azuread_service_principal.existing[0].object_id
  )
}

# Get current Azure AD client configuration to set default application owner.
data "azuread_client_config" "current" {}

# Look up existing service principal when client ID is provided but object ID is not.
data "azuread_service_principal" "existing" {
  count     = !local.create_application && var.azure_application_service_principal_object_id == null ? 1 : 0
  client_id = var.azure_application_client_id
}

# Azure AD application for integration.
resource "azuread_application" "integration" {
  count        = local.create_application ? 1 : 0
  display_name = local.app_name
  owners = coalescelist(
    var.application_owners,
    [data.azuread_client_config.current.object_id]
  )
  marketing_url = "https://www.upwind.io/"
  web {
    homepage_url = "https://www.upwind.io/"
  }
  password {
    end_date     = var.application_password_expiration_date
    display_name = "${local.app_name}_client_secret"
  }
}

# Service principal for the integration application.
resource "azuread_service_principal" "integration" {
  count     = local.create_application ? 1 : 0
  client_id = azuread_application.integration[0].client_id
  owners = coalescelist(
    var.application_owners,
    [data.azuread_client_config.current.object_id]
  )
}
