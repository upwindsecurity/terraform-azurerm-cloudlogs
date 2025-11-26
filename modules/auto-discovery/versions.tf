terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.30.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.4.0"
    }
  }
}
