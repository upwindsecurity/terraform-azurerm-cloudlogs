# Verifies the two authentication flows of the eventhub module with mocked
# providers (no Azure credentials needed):
#   * WIF (fetcher_* supplied): no app registration, no Key Vault, WIF SP
#     materialized and granted the Event Hub role.
#   * Legacy (no fetcher_* input): app registration + Key Vault as before.
#   * WIF with a pre-created SP object ID: nothing from azuread is used.

mock_provider "azurerm" {
  override_data {
    target = data.azurerm_client_config.current_sp
    values = {
      object_id = "66666666-6666-6666-6666-666666666666"
    }
  }
  override_data {
    target = data.azurerm_subscription.current
    values = {
      subscription_id = "87654321-4321-4321-4321-210987654321"
      id              = "/subscriptions/87654321-4321-4321-4321-210987654321"
    }
  }
}

mock_provider "azuread" {}

variables {
  tenant_id                      = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id = "87654321-4321-4321-4321-210987654321"
  stream_subscription_ids        = ["87654321-4321-4321-4321-210987654321"]
  resource_suffix                = "test"
}

run "wif_with_fetcher_client_id" {
  command = plan

  variables {
    fetcher_app_client_id                = "33333333-3333-3333-3333-333333333333"
    diagnostic_setting_enable_entra_logs = false
  }

  assert {
    condition     = output.workload_identity_federation_enabled == true
    error_message = "WIF should engage when fetcher_app_client_id is supplied."
  }
  assert {
    condition     = length(azuread_application.integration) == 0
    error_message = "WIF mode must not create an app registration."
  }
  assert {
    condition     = length(azuread_service_principal.integration) == 0
    error_message = "WIF mode must not create the legacy service principal."
  }
  assert {
    condition     = length(azuread_service_principal.wif) == 1
    error_message = "WIF mode must materialize the WIF service principal."
  }
  assert {
    condition     = length(azurerm_key_vault.integration) == 0 && length(azurerm_key_vault_secret.sp_client_id) == 0 && length(azurerm_key_vault_secret.sp_client_secret) == 0
    error_message = "WIF mode must not create a Key Vault or secrets."
  }
  assert {
    condition     = length(azurerm_role_assignment.kv_secrets_officer) == 0 && length(azurerm_role_assignment.kv_secrets_user) == 0
    error_message = "WIF mode must not create Key Vault role assignments."
  }
  assert {
    condition     = length(data.azuread_service_principal.onboarding_sp) == 0
    error_message = "WIF mode must not look up the onboarding service principal."
  }
  assert {
    condition     = azurerm_role_assignment.eh_receiver.role_definition_name == "Azure Event Hubs Data Receiver"
    error_message = "The WIF SP must be granted Event Hubs Data Receiver."
  }
  assert {
    condition     = output.application_client_id == "33333333-3333-3333-3333-333333333333"
    error_message = "application_client_id should be the WIF app registration."
  }
  assert {
    condition     = output.key_vault_name == null && output.application_name == null
    error_message = "key_vault_name and application_name should be null in WIF mode."
  }
}

run "wif_with_existing_sp_object_id" {
  command = plan

  variables {
    fetcher_app_service_principal_object_id = "44444444-4444-4444-4444-444444444444"
  }

  assert {
    condition     = output.workload_identity_federation_enabled == true
    error_message = "WIF should engage when fetcher_app_service_principal_object_id is supplied."
  }
  assert {
    condition     = length(azuread_service_principal.wif) == 0
    error_message = "A supplied SP object ID must skip SP creation."
  }
  assert {
    condition     = azurerm_role_assignment.eh_receiver.principal_id == "44444444-4444-4444-4444-444444444444"
    error_message = "Roles must be assigned to the supplied SP object ID."
  }
  assert {
    condition     = output.application_client_id == null
    error_message = "application_client_id is null when only the SP object ID is supplied."
  }
}

run "legacy_fallback_without_fetcher_inputs" {
  command = plan

  variables {
    onboarding_service_principal_client_id = "55555555-5555-5555-5555-555555555555"
  }

  assert {
    condition     = output.workload_identity_federation_enabled == false
    error_message = "Without fetcher_* inputs the legacy flow must be used."
  }
  assert {
    condition     = length(azuread_application.integration) == 1 && length(azuread_service_principal.integration) == 1
    error_message = "Legacy flow must create the app registration and service principal."
  }
  assert {
    condition     = length(azuread_service_principal.wif) == 0
    error_message = "Legacy flow must not create the WIF service principal."
  }
  assert {
    condition     = length(azurerm_key_vault.integration) == 1 && length(azurerm_key_vault_secret.sp_client_id) == 1 && length(azurerm_key_vault_secret.sp_client_secret) == 1
    error_message = "Legacy flow must create the Key Vault and both secrets."
  }
  assert {
    condition     = length(azurerm_role_assignment.kv_secrets_officer) == 1 && length(azurerm_role_assignment.kv_secrets_user) == 1
    error_message = "Legacy flow must create the Key Vault role assignments."
  }
  assert {
    condition     = output.key_vault_name == "upwindsecurity-test"
    error_message = "key_vault_name should be set in legacy mode."
  }
}

run "legacy_requires_onboarding_sp" {
  command = plan

  expect_failures = [
    data.azuread_service_principal.onboarding_sp,
  ]
}

run "wif_pinned_off_ignores_fetcher_inputs" {
  command = plan

  variables {
    use_workload_identity_federation       = false
    fetcher_app_client_id                  = "33333333-3333-3333-3333-333333333333"
    onboarding_service_principal_client_id = "55555555-5555-5555-5555-555555555555"
  }

  assert {
    condition     = output.workload_identity_federation_enabled == false
    error_message = "use_workload_identity_federation = false must pin the legacy flow."
  }
  assert {
    condition     = length(azurerm_key_vault.integration) == 1 && length(azuread_application.integration) == 1
    error_message = "Pinned legacy flow must still create the Key Vault and app registration."
  }
}
