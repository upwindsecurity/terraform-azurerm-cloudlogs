terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.30, < 4.42"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.4"
    }
  }
}
