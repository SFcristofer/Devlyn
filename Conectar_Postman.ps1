# Script Puente para conectar Terminal con Postman (Data Cloud Query API v2)
# Proyecto: Devlyn - TechPatient360

try {
    Write-Host "--- Obteniendo credenciales de Salesforce... ---" -ForegroundColor Cyan
    $orgInfo = sf org display --json | ConvertFrom-Json
    
    if ($null -eq $orgInfo.result) {
        throw "No se encontró una organización activa. Por favor ejecuta: sf org login web"
    }

    $token = $orgInfo.result.accessToken
    $instanceUrl = $orgInfo.result.instanceUrl
    $endpoint = "$instanceUrl/services/data/v60.0/ssot/queryv2"

    Write-Host "`n--- CONFIGURACIÓN PARA POSTMAN ---" -ForegroundColor Green
    Write-Host "MÉTODO: POST"
    Write-Host "URL: $endpoint"
    Write-Host "AUTH: Bearer Token"
    Write-Host "TOKEN: $token"
    Write-Host "----------------------------------`n"

    # Generar comando cURL para importar directo en Postman
    $curl = "curl --location --request POST '$endpoint' --header 'Authorization: Bearer $token' --header 'Content-Type: application/json' --data-raw '{`\"sql`\": `\"SELECT ssot__Id__c FROM UnifiedssotIndividualDev2__dlm LIMIT 1`\"}'"
    
    Set-Clipboard -Value $curl
    Write-Host "¡Comando cURL copiado al portapapeles!" -ForegroundColor Yellow
    Write-Host "En Postman, haz clic en 'Import' -> 'Raw text' y pega (Ctrl+V) el comando."
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
