moved {
  from = azuread_application.integration
  to   = module.app_registration.azuread_application.integration
}

moved {
  from = azuread_service_principal.integration
  to   = module.app_registration.azuread_service_principal.integration
}
