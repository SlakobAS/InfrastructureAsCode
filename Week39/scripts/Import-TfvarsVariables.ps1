# Parametere
param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,
    
    [Parameter(Mandatory=$true)]
    [string]$TfvarsFilePath,
    
    [string]$Prefix = ""
)

# Les filen linje for linje
$lines = Get-Content -Path $TfvarsFilePath

# Teller for suksessfulle imports
$successCount = 0

foreach ($line in $lines) {
    # Hopp over tomme linjer og kommentarer
    if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
        continue
    }
    
    # Parse linjen (format: variabel_navn = "verdi")
    if ($line -match '^\s*([a-zA-Z0-9_-]+)\s*=\s*(.+)$') {
        $variableName = $matches[1].Trim()
        $variableValue = $matches[2].Trim()
        
        # Fjern anførselstegn hvis de finnes
        $variableValue = $variableValue -replace '^"(.*)"$', '$1'
        $variableValue = $variableValue -replace "^'(.*)'$", '$1'
        
        # Lag secret navn (med prefix hvis angitt)
        if ($Prefix) {
            $secretName = "$Prefix-$variableName"
        } else {
            $secretName = $variableName
        }
        
        # Lagre til Key Vault
        try {
            az keyvault secret set `
                --vault-name $KeyVaultName `
                --name $secretName `
                --value $variableValue `
                --output none
            
            Write-Host "✓ Lagret: $secretName = $variableValue"
            $successCount++
        }
        catch {
            Write-Host "✗ Feil ved lagring av $secretName : $_" -ForegroundColor Red
        }
    }
}

Write-Host "`n$successCount secrets ble lagret i Key Vault '$KeyVaultName'"