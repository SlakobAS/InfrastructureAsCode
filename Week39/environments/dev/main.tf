terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.40.0"
    }
  }
  backend "azurerm" {
    # see backend.hcl for non-secret settings
    # use_azuread_auth = true  # uncomment to use Azure AD auth (instead of access key)
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}