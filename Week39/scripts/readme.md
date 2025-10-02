Run: Import-TfvarsVariables.ps1

```bash

# Uten prefix
./Import-TfvarsVariables.ps1 `
    -KeyVaultName "mitt-keyvault" `
    -TfvarsFilePath "./terraform.tfvars"

# Med prefix (anbefalt for å organisere secrets)
./Import-TfvarsVariables.ps1 `
    -KeyVaultName "mitt-keyvault" `
    -TfvarsFilePath "./terraform.tfvars" `
    -Prefix "terraform"

# E.g i dev
./Import-TfvarsVariables.ps1 `
     -KeyVaultName "kv-tfstate-o8xb7l" `
     -TfvarsFilePath "../environments/dev/dev.tfvars"

```

Get signed on object-id:
az ad signed-in-user show --query id -o tsv