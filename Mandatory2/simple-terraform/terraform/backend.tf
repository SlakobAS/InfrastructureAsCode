# Backend configuration provided via -backend-config flag
# This keeps the backend block flexible for different environments
terraform {
  backend "azurerm" {
    # Configuration will be provided via ../shared/backend.hcl 
  }
}
