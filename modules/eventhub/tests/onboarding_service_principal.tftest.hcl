# Verifies both authentication flows of the eventhub module with mocked
# providers (no Azure credentials needed).

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

mock_provider "azuread" {
  override_data {
    target = data.azuread_client_config.current
    values = {
      object_id = "66666666-6666-6666-6666-666666666666"
    }
  }
  override_data {
    target = data.azuread_service_principal.onboarding_sp
    values = {
      object_id = "77777777-7777-7777-7777-777777777777"
    }
  }
}

variables {
  tenant_id                              = "12345678-1234-1234-1234-123456789012"
  infrastructure_subscription_id         = "87654321-4321-4321-4321-210987654321"
  stream_subscription_ids                = ["87654321-4321-4321-4321-210987654321"]
  resource_suffix                        = "test"
  onboarding_service_principal_client_id = "55555555-5555-5555-5555-555555555555"
}

run "onboarding_sp_looked_up_by_client_id" {
  command = plan

  variables {
    use_onboarding_service_principal = true
  }

  assert {
    condition     = length(azuread_application.integration) == 0 && length(azuread_service_principal.integration) == 0
    error_message = "Must not create an app registration or service principal."
  }
  assert {
    condition     = length(azurerm_key_vault.integration) == 0 && length(azurerm_key_vault_secret.sp_client_id) == 0 && length(azurerm_key_vault_secret.sp_client_secret) == 0
    error_message = "Must not create a Key Vault or secrets."
  }
  assert {
    condition     = length(azurerm_role_assignment.kv_secrets_officer) == 0 && length(azurerm_role_assignment.kv_secrets_user) == 0
    error_message = "Must not create Key Vault role assignments."
  }
  assert {
    condition     = length(data.azuread_service_principal.onboarding_sp) == 1
    error_message = "The onboarding service principal must be looked up by client ID."
  }
  assert {
    condition     = azurerm_role_assignment.eh_receiver.principal_id == "77777777-7777-7777-7777-777777777777" && azurerm_role_assignment.eh_receiver.role_definition_name == "Azure Event Hubs Data Receiver"
    error_message = "The onboarding service principal must be granted Event Hubs Data Receiver."
  }
  assert {
    condition     = azurerm_role_assignment.monitoring_reader.principal_id == "77777777-7777-7777-7777-777777777777"
    error_message = "The onboarding service principal must be granted Monitoring Reader."
  }
  assert {
    condition     = output.application_client_id == "55555555-5555-5555-5555-555555555555"
    error_message = "application_client_id must be the onboarding service principal's client ID."
  }
  assert {
    condition     = output.key_vault_name == null && output.application_name == null
    error_message = "key_vault_name and application_name must be null."
  }
}

run "onboarding_sp_object_id_skips_graph_lookup" {
  command = plan

  variables {
    use_onboarding_service_principal       = true
    onboarding_service_principal_object_id = "44444444-4444-4444-4444-444444444444"
  }

  assert {
    condition     = length(data.azuread_service_principal.onboarding_sp) == 0
    error_message = "A supplied object ID must skip the service principal lookup."
  }
  assert {
    condition     = azurerm_role_assignment.eh_receiver.principal_id == "44444444-4444-4444-4444-444444444444"
    error_message = "Roles must be assigned to the supplied object ID."
  }
}

run "default_keeps_key_vault_flow" {
  command = plan

  assert {
    condition     = length(azuread_application.integration) == 1 && length(azuread_service_principal.integration) == 1
    error_message = "By default the app registration and service principal must be created."
  }
  assert {
    condition     = length(azurerm_key_vault.integration) == 1 && length(azurerm_key_vault_secret.sp_client_id) == 1 && length(azurerm_key_vault_secret.sp_client_secret) == 1
    error_message = "By default the Key Vault and both secrets must be created."
  }
  assert {
    condition     = azurerm_role_assignment.kv_secrets_user[0].principal_id == "77777777-7777-7777-7777-777777777777"
    error_message = "By default the onboarding service principal must be granted Key Vault Secrets User."
  }
  assert {
    condition     = output.key_vault_name == "upwindsecurity-test"
    error_message = "key_vault_name must be set by default."
  }
}

run "invalid_object_id_rejected" {
  command = plan

  variables {
    onboarding_service_principal_object_id = "not-a-guid"
  }

  expect_failures = [
    var.onboarding_service_principal_object_id,
  ]
}
