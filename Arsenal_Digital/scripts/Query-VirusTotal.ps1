<#
.SYNOPSIS
    Consulta la API de VirusTotal para un archivo sospechoso.
.DESCRIPTION
    Calcula el hash SHA-256 de un archivo local y consulta su estado en VirusTotal 
    de manera automática. Requiere una API Key configurada.
#>
param(
    [Parameter(Mandatory=$true, HelpMessage="Ruta al archivo sospechoso a escanear")]
    [string]$FilePath
)

$secretPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\SECRETS\VT_API_KEY.txt"

if (-not (Test-Path $secretPath)) {
    Write-Error "No se encontró VT_API_KEY.txt en la carpeta SECRETS."
    Write-Host "Por favor, crea el archivo y pega tu API Key de VirusTotal dentro." -ForegroundColor Yellow
    exit 1
}

$apiKey = (Get-Content -Path $secretPath -TotalCount 1).Trim()
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Error "La API Key está vacía."
    exit 1
}

if (-not (Test-Path $FilePath)) {
    Write-Error "El archivo no existe: $FilePath"
    exit 1
}

Write-Host "Calculando SHA-256 de: $FilePath" -ForegroundColor Cyan
$fileHash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
Write-Host "Hash: $fileHash"

Write-Host "Consultando VirusTotal..." -ForegroundColor Cyan
$url = "https://www.virustotal.com/api/v3/files/$fileHash"
$headers = @{
    "x-apikey" = $apiKey
}

try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop
    $stats = $response.data.attributes.last_analysis_stats
    
    Write-Host "`n=== RESULTADO DE VIRUSTOTAL ===" -ForegroundColor Yellow
    Write-Host "Malicioso : $($stats.malicious)" -ForegroundColor Red
    Write-Host "Sospechoso: $($stats.suspicious)" -ForegroundColor Yellow
    Write-Host "Limpio    : $($stats.undetected)" -ForegroundColor Green
    
    if ($stats.malicious -gt 0) {
        Write-Host "`n¡ALERTA! El archivo es conocido como MALICIOSO por varios motores." -ForegroundColor Red
    } elseif ($stats.undetected -gt 0 -and $stats.malicious -eq 0) {
        Write-Host "`nEl archivo parece limpio según los motores actuales." -ForegroundColor Green
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 'NotFound') {
        Write-Host "`nEl archivo no existe en la base de datos de VirusTotal. (Hash desconocido)" -ForegroundColor Yellow
    } else {
        Write-Error "Error de conexión con la API: $($_.Exception.Message)"
    }
}
