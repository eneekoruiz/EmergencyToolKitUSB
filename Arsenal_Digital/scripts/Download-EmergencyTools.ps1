<#
.SYNOPSIS
    Descarga herramientas oficiales de emergencia (Sysinternals, etc.)
.DESCRIPTION
    En lugar de distribuir binarios que pesan mucho o dan falsos positivos en AV, 
    este script descarga herramientas frescas desde los repositorios oficiales de Microsoft o Sysinternals.
    Ideal para ejecutar justo antes de salir de rescate para tener las últimas versiones.
#>

$ToolsDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\tools"
if (-not (Test-Path $ToolsDir)) {
    New-Item -ItemType Directory -Path $ToolsDir | Out-Null
}

Write-Host "Actualizando herramientas del Arsenal Digital en $ToolsDir..." -ForegroundColor Cyan

# Sysinternals Suite (Zip)
$sysinternalsUrl = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$sysZip = Join-Path $ToolsDir "SysinternalsSuite.zip"
$sysExtract = Join-Path $ToolsDir "Sysinternals"

Write-Host "Descargando Sysinternals Suite..."
Invoke-WebRequest -Uri $sysinternalsUrl -OutFile $sysZip
if (Test-Path $sysExtract) { Remove-Item -Path $sysExtract -Recurse -Force }
Expand-Archive -Path $sysZip -DestinationPath $sysExtract -Force
Remove-Item $sysZip
Write-Host "Sysinternals actualizado." -ForegroundColor Green

# Herramientas Específicas de Sysinternals sueltas (por si no quieres descomprimir todo)
# Descarga directa vía HTTPS (Sysinternals Live)
$liveUrl = "https://live.sysinternals.com"
$criticalTools = @("procexp.exe", "procmon.exe", "autoruns.exe", "tcpview.exe", "pslist.exe", "psexec.exe")

$sysLiveDir = Join-Path $ToolsDir "Sysinternals_Live"
if (-not (Test-Path $sysLiveDir)) { New-Item -ItemType Directory -Path $sysLiveDir | Out-Null }

foreach ($tool in $criticalTools) {
    Write-Host "Descargando $tool desde Sysinternals Live..."
    Invoke-WebRequest -Uri "$liveUrl/$tool" -OutFile (Join-Path $sysLiveDir $tool)
}

# Nota sobre NirSoft:
# Las herramientas de NirSoft (como ProduKey o recuparadores de contraseñas) son muy útiles
# pero el 99% de los antivirus las marcan como troyanos o hacktools.
# Por diseño y seguridad, no las descargamos automáticamente aquí para evitar que Windows Defender
# ponga en cuarentena toda tu carpeta de herramientas.
# Si necesitas NirSoft, descárgalo manualmente en un entorno controlado (VM) y ponlo en un zip con contraseña.

Write-Host "Todas las herramientas descargadas con éxito." -ForegroundColor Green
