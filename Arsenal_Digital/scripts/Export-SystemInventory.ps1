<#
.SYNOPSIS
    Extrae hardware, software y claves de licencia sin dejar rastro.
.DESCRIPTION
    Extrae la BIOS Product Key, el nmero de serie del fabricante (Service Tag), 
    la IP, la versin exacta del SO y el software instalado, guardndolo en JSON/TXT.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$reportFile = Join-Path $Destination "SystemInventory_$timestamp.txt"

Write-Host "Extrayendo Inventario del Sistema..." -ForegroundColor Cyan

$content = @()
$content += "========================================="
$content += " INVENTARIO DE SISTEMA"
$content += " Hostname: $env:COMPUTERNAME"
$content += " Fecha: $(Get-Date)"
$content += "========================================="

# 1. Informacin de BIOS y Fabricante
Write-Host "-> Consultando BIOS y Hardware"
$bios = Get-WmiObject Win32_BIOS
$sys = Get-WmiObject Win32_ComputerSystem
$content += "`n[ HARDWARE ]"
$content += "Fabricante : $($sys.Manufacturer)"
$content += "Modelo     : $($sys.Model)"
$content += "N. Serie   : $($bios.SerialNumber) (Service Tag)"

# 2. Clave de Windows
Write-Host "-> Consultando Licencias"
$content += "`n[ LICENCIA ]"
try {
    $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    if ([string]::IsNullOrWhiteSpace($key)) { $key = "No encontrada en BIOS (Posible licencia digital/Retail)" }
    $content += "Clave Original de BIOS (OA3): $key"
} catch {
    $content += "Clave Original de BIOS (OA3): Error al consultar WMI."
}

# 3. Informacin del Sistema Operativo
$os = Get-WmiObject Win32_OperatingSystem
$content += "`n[ SISTEMA OPERATIVO ]"
$content += "OS       : $($os.Caption)"
$content += "Version  : $($os.Version)"
$content += "Arquitect: $($os.OSArchitecture)"

# 4. Software Instalado (Uninstall Key)
Write-Host "-> Recolectando Software Instalado (Tardarǭ unos segundos)..."
$content += "`n[ SOFTWARE INSTALADO ]"
$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue | 
             Where-Object { $_.DisplayName -ne $null } | 
             Select-Object DisplayName, DisplayVersion, Publisher | 
             Sort-Object DisplayName

$content += ($installed | Format-Table -AutoSize | Out-String)

$content | Set-Content -Path $reportFile
Write-Host "Auditora de Hardware y Licencias guardada en $reportFile" -ForegroundColor Green
