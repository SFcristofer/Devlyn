
# Script para conectar Salesforce Data Cloud con Postman
# Autor: Gemini CLI

Write-Host "--- Obteniendo credenciales de Salesforce ---" -ForegroundColor Cyan

# Obtener los datos de la org por defecto
$orgData = sf org display --json | ConvertFrom-Json

if ($orgData.status -eq 0) {
    $accessToken = $orgData.result.accessToken
    $instanceUrl = $orgData.result.instanceUrl
    
    Write-Host "`n¡Conexión Exitosa!" -ForegroundColor Green
    Write-Host "-------------------------------------------"
    Write-Host "Copia estos valores en tus variables de Postman:" -ForegroundColor Yellow
    Write-Host "URL: " -NoNewline; Write-Host "$instanceUrl" -ForegroundColor White
    Write-Host "TOKEN: " -NoNewline; Write-Host "$accessToken" -ForegroundColor White
    Write-Host "-------------------------------------------"
    
    # Crear un archivo rápido para referencia
    $postmanConfig = @{
        url = $instanceUrl
        token = $accessToken
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    } | ConvertTo-Json
    
    $postmanConfig | Out-File -FilePath "./postman_config.json"
    Write-Host "Datos guardados en ./postman_config.json" -ForegroundColor Gray
} else {
    Write-Host "Error: No se pudo conectar con Salesforce. Asegúrate de estar logueado con 'sf org login web'." -ForegroundColor Red
}

Write-Host "`nPresiona cualquier tecla para cerrar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
