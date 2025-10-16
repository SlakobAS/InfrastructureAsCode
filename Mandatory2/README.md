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
