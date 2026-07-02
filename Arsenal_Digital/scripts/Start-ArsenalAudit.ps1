<#
.SYNOPSIS
    Inicia una transcripción inmutable de la sesión de respuesta a incidentes.
.DESCRIPTION
    Este script activa Start-Transcript para guardar un registro auditable de 
    absolutamente todo lo que se teclea y se muestra en pantalla durante la sesión 
    de PowerShell. Evita alteraciones accidentales y garantiza la cadena de custodia.
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$CaseName = "Incident"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\CASOS\$CaseName"

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$transcriptPath = Join-Path $logDir "AuditLog_$timestamp.txt"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " INICIANDO AUDITORIA GLOBAL (CAJA NEGRA) " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "A partir de este momento, cada comando está siendo grabado." -ForegroundColor Yellow
Write-Host "Archivo de volcado: $transcriptPath" -ForegroundColor Yellow

Start-Transcript -Path $transcriptPath -Append -IncludeInvocationHeader

Write-Host "`nPara detener la grabación al terminar el trabajo, ejecuta: Stop-Transcript" -ForegroundColor Green
