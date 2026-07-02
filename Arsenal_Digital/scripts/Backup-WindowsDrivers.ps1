<#
.SYNOPSIS
    Exporta todos los drivers de terceros instalados en Windows.
.DESCRIPTION
    Extrae los controladores (drivers) de red, chipset, audio, vídeo, etc., del sistema actual.
    Muy ǧtil para ejecutar justo ANTES de formatear un equipo o reemplazar el disco duro, 
    asegurando que tras reinstalar Windows no te falten drivers exticos.
.PARAMETER Destination
    Directorio donde se guardarǭn las carpetas de drivers.
.EXAMPLE
    .\Backup-WindowsDrivers.ps1 -Destination "E:\Rescates\Cliente1\Drivers"
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

Write-Host "Iniciando extraccin de drivers de terceros hacia $Destination..." -ForegroundColor Cyan
Write-Host "Esto puede tardar varios minutos..."

try {
    Export-WindowsDriver -Online -Destination $Destination -ErrorAction Stop
    Write-Host "Drivers exportados con xito!" -ForegroundColor Green
} catch {
    Write-Error "Fallo al exportar los drivers. Asegǧrate de estar ejecutando PowerShell como Administrador."
    Write-Error $_.Exception.Message
}
