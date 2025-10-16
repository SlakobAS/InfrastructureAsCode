# ============================================
# POWERSHELL SCRIPT: deploy-files-and-folders.ps1
# ============================================
# Genererer komplett prosjektstruktur for Del 1: Build Once, Deploy Many
# 
# Kjøre scriptet i PowerShell:
#  pwsh ./deploy-files-and-folders.ps1

# Flytt en mappe opp
Set-Location ..

param(
    [string]$ProjectName = "simple-terraform"
)

Write-Host "🚀 Oppretter prosjekt: $ProjectName" -ForegroundColor Green
Write-Host ""

# Opprett hovedmappe
New-Item -ItemType Directory -Force -Path $ProjectName | Out-Null
Set-Location $ProjectName

# Opprett mappestruktur
Write-Host "📁 Oppretter mappestruktur..." -ForegroundColor Cyan
$folders = @(
    "terraform",
    "environments"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    Write-Host "  ✓ $folder" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📝 Genererer filer..." -ForegroundColor Cyan

# ============================================
# TERRAFORM FILES
# ============================================

# terraform/versions.tf
Write-Host "  ✓ terraform/versions.tf" -ForegroundColor Gray
@'
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
}
'@ | Out-File -FilePath "terraform/versions.tf" -Encoding UTF8

# terraform/backend.tf
Write-Host "  ✓ terraform/backend.tf" -ForegroundColor Gray
@'
# Backend configuration provided via -backend-config flag
# This keeps the backend block flexible for different environments
terraform {
  backend "azurerm" {
    # Configuration will be provided via ../shared/backend.hcl 
  }
}
'@ | Out-File -FilePath "terraform/backend.tf" -Encoding UTF8

# terraform/variables.tf
Write-Host "  ✓ terraform/variables.tf" -ForegroundColor Gray
@'
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
}
'@ | Out-File -FilePath "terraform/variables.tf" -Encoding UTF8

# terraform/main.tf
Write-Host "  ✓ terraform/main.tf" -ForegroundColor Gray
@'
# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location

  tags = local.tags
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                = local.sa_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  
  min_tls_version           = "TLS1_2"

  tags = local.tags
}

# Storage Container
resource "azurerm_storage_container" "demo" {
  name                  = local.sc_name
  storage_account_id   = azurerm_storage_account.main.id
  container_access_type = "private"
}
'@ | Out-File -FilePath "terraform/main.tf" -Encoding UTF8


# terraform/locals.tf
Write-Host "  ✓ terraform/locals.tf" -ForegroundColor Gray
@'
locals {
  resource_prefix = "demo"
  rg_name       = "rg-${var.project_name}-${var.environment}-jakob"
  sa_name       = "st${var.project_name}${var.environment}${random_string.suffix.result}"
  sc_name       = "container-${var.environment}"

  tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}
'@ | Out-File -FilePath "terraform/locals.tf" -Encoding UTF8

# terraform/outputs.tf
Write-Host "  ✓ terraform/outputs.tf" -ForegroundColor Gray
@'
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "environment" {
  description = "Deployed environment"
  value       = var.environment
}
'@ | Out-File -FilePath "terraform/outputs.tf" -Encoding UTF8

# ============================================
# ENVIRONMENT CONFIGS
# ============================================

# environments/dev.tfvars
Write-Host "  ✓ environments/dev.tfvars" -ForegroundColor Gray
@'
environment  = "dev"
location     = "norwayeast"
project_name = "demo"
account_tier = "Standard"
account_replication_type = "LRS"
'@ | Out-File -FilePath "environments/dev.tfvars" -Encoding UTF8

# environments/test.tfvars
Write-Host "  ✓ environments/test.tfvars" -ForegroundColor Gray
@'
environment  = "test"
location     = "norwayeast"
project_name = "demo"
account_tier = "Standard"
account_replication_type = "GRS"
'@ | Out-File -FilePath "environments/test.tfvars" -Encoding UTF8

Write-Host " ✓ environments/prod.tfvars" -ForegroundColor Gray
@'
environment  = "prod"
location     = "norwayeast"
project_name = "demo"
account_tier = "Premium"
account_replication_type = "GRS"
'@ | Out-File -FilePath "environments/prod.tfvars" -Encoding UTF8

# ============================================
# DOCUMENTATION
# ============================================

# README.md
Set-Location ..

Write-Host "  ✓ README.md" -ForegroundColor Gray
@'
# Simple Terraform - Build Once, Deploy Many Demo

Dette prosjektet demonstrerer "Build Once, Deploy Many" prinsippet med Terraform og Azure.

## 🎯 Konsept

**Build Once, Deploy Many** betyr:
- Bygg artifact ÉN gang
- Deploy SAMME artifact til flere miljøer
- Garantert konsistens mellom miljøer

## 📁 Struktur

```
simple-terraform/
├── terraform/          # Terraform kode (felles)
├── environments/       # Miljø-spesifikk .tfvars filer
shared/
└── backend.hcl      # Backend konfigurasjon (felles)
```

### Forutsetninger
- Terraform >= 1.5.0
- Azure CLI
- Git (for versjonering)

### Steg 1: Bygg mappestruktur
```bash
# Kjøre scriptet i PowerShell fra Mandatory2/deployScript mappen:
pwsh ./deploy-files-and-folders.ps1
```

## Steg 2: 
'@ | Out-File -FilePath "README.md" -Encoding UTF8


# ============================================
# FINISH
# ============================================

Write-Host ""
Write-Host "✅ Prosjekt opprettet!" -ForegroundColor Green
Write-Host ""
Write-Host "📂 Prosjekt: $ProjectName" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Neste steg:" -ForegroundColor Yellow
Write-Host "  1. cd $ProjectName" -ForegroundColor Gray
Write-Host "  2. Les README.md for instruksjoner" -ForegroundColor Gray
Write-Host "  3. Bygg artifact: .\scripts\build.ps1" -ForegroundColor Gray
Write-Host "  4. Deploy: .\scripts\deploy.ps1 -Environment dev -Artifact <artifact>" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tips: Sjekk README.md for full guide" -ForegroundColor Cyan
Write-Host ""
