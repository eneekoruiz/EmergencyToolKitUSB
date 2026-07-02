<#
.SYNOPSIS
    Recolecta informacin vital (triaje) de un sistema vivo (Incident Response).
.DESCRIPTION
    Extrae procesos en ejecucin, conexiones de red activas, tareas programadas, y servicios 
    del sistema actual y los guarda en archivos CSV dentro de una carpeta especfica.
    Ideal para ejecutar en cuanto llegas a un PC comprometido antes de apagarlo.
.PARAMETER Destination
    Directorio donde se guardarǭ la evidencia.
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = Join-Path $Destination "Triage_$timestamp"
New-Item -ItemType Directory -Path $outDir | Out-Null

Write-Host "Iniciando recoleccin de triaje en vivo en $outDir" -ForegroundColor Cyan

# Procesos
Write-Host "-> Recolectando procesos..."
Get-Process | Select-Object Id, ProcessName, Path, MainWindowTitle, StartTime, CPU | Export-Csv (Join-Path $outDir "Procesos.csv") -NoTypeInformation

# Conexiones de red (Requiere Admin)
Write-Host "-> Recolectando conexiones de red..."
Get-NetTCPConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | Export-Csv (Join-Path $outDir "ConexionesRed.csv") -NoTypeInformation

# Servicios
Write-Host "-> Recolectando servicios..."
Get-Service | Select-Object Name, DisplayName, Status, StartType | Export-Csv (Join-Path $outDir "Servicios.csv") -NoTypeInformation

# Tareas Programadas
Write-Host "-> Recolectando tareas programadas..."
Get-ScheduledTask | Select-Object TaskName, TaskPath, State | Export-Csv (Join-Path $outDir "TareasProgramadas.csv") -NoTypeInformation

# Usuarios Locales
Write-Host "-> Recolectando usuarios locales..."
Get-LocalUser | Select-Object Name, Enabled, LastLogon | Export-Csv (Join-Path $outDir "UsuariosLocales.csv") -NoTypeInformation

Write-Host "Triaje finalizado con xito. Revisa la carpeta $outDir" -ForegroundColor Green
