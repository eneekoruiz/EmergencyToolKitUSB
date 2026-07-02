<#
.SYNOPSIS
    Realiza un respaldo avanzado de la configuracin de red.
.DESCRIPTION
    Exporta adaptadores, IP, DNS, tabla de rutas (route print), ARP, 
    y reglas del firewall de Windows a un archivo de texto. 
    Crucial antes de migrar un servidor a otro hardware.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$reportFile = Join-Path $Destination "NetworkConfigBackup_$timestamp.txt"

Write-Host "Recolectando configuracin de red en $reportFile..." -ForegroundColor Cyan

$content = @()
$content += "========================================="
$content += " RESPALDO DE CONFIGURACIN DE RED"
$content += " Fecha: $(Get-Date)"
$content += " Computadora: $env:COMPUTERNAME"
$content += "========================================="

$content += "`n[1] IPCONFIG /ALL"
$content += "-----------------------------------------"
$content += (ipconfig /all)

$content += "`n[2] TABLA DE ENRUTAMIENTO (Route Print)"
$content += "-----------------------------------------"
$content += (route print)

$content += "`n[3] TABLA ARP"
$content += "-----------------------------------------"
$content += (arp -a)

$content += "`n[4] ADAPTADORES DE RED (PowerShell)"
$content += "-----------------------------------------"
$content += (Get-NetAdapter | Format-Table -AutoSize | Out-String)
$content += (Get-NetIPAddress | Format-Table -AutoSize | Out-String)
$content += (Get-DnsClientServerAddress | Format-Table -AutoSize | Out-String)

$content += "`n[5] ESTADO DEL FIREWALL"
$content += "-----------------------------------------"
$content += (netsh advfirewall show allprofiles)

$content | Set-Content -Path $reportFile

Write-Host "Configuracin respaldada con xito." -ForegroundColor Green
