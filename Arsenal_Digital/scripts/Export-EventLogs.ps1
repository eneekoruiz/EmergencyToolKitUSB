<#
.SYNOPSIS
    Exporta todos los registros de eventos de Windows (.evtx).
.DESCRIPTION
    Ideal para extraccin rpida de evidencias o diagnstico. Comprime la carpeta 
    completa de EventLogs (Application, Security, System, etc.) hacia el USB.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$tempDir = Join-Path $env:TEMP "EventLogs_$timestamp"
$zipFile = Join-Path $Destination "EventLogs_Backup_$timestamp.zip"

Write-Host "Iniciando exportacin de Registros de Eventos a $Destination..." -ForegroundColor Cyan

try {
    # Usar wevtutil para exportar los 3 ms importantes por si la copia directa falla por bloqueos
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    Write-Host "Exportando Log 'System'..."
    wevtutil epl System (Join-Path $tempDir "System_Export.evtx") /ow:true
    
    Write-Host "Exportando Log 'Application'..."
    wevtutil epl Application (Join-Path $tempDir "Application_Export.evtx") /ow:true
    
    Write-Host "Exportando Log 'Security' (Requiere Admin)..."
    wevtutil epl Security (Join-Path $tempDir "Security_Export.evtx") /ow:true

    Write-Host "Comprimiendo logs en $zipFile..."
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile -Force
    
    # Limpieza
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "Logs exportados correctamente." -ForegroundColor Green

} catch {
    Write-Error "Ocurri un error al exportar los logs: $_"
}
