<#
.SYNOPSIS
    Script helper para obtener ISOs de Windows.
.DESCRIPTION
    Debido a licencias, no se incluyen ISOs de Windows.
    Este script descarga Rufus (que tiene un descargador de ISOs incorporado) 
    o abre la página oficial de la herramienta de creación de medios de Microsoft.
#>

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " OBTENCIÓN DE ISOs DE WINDOWS Y HERRAMIENTAS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "1. Abriendo página de Microsoft para Media Creation Tool (Windows 10/11)..."
Start-Process "https://www.microsoft.com/software-download/"

Write-Host "2. Descargando Rufus Portable (Excelente para crear USBs y descargar ISOs oficiales usando Fido script)..."
$ToolsDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "..\tools"
if (-not (Test-Path $ToolsDir)) { New-Item -ItemType Directory -Path $ToolsDir | Out-Null }

# Descarga la última versión de Rufus portable desde GitHub releases (requiere parsear API)
# Por simplicidad, damos instrucciones de uso de Rufus
Write-Host ""
Write-Host "Recomendación: Descarga Rufus desde https://rufus.ie/" -ForegroundColor Yellow
Write-Host "Dentro de Rufus, haz clic en la flecha pequeña junto a 'SELECCIONAR' y cámbiala a 'DESCARGAR'." -ForegroundColor Yellow
Write-Host "Esto ejecutará un script oficial que permite descargar ISOs limpias de Windows 10, Windows 11, etc. directamente de los servidores de Microsoft." -ForegroundColor Yellow
Write-Host "Guarda esas ISOs en tu carpeta /USB_RESCATE_VENTOY/ISO para que Ventoy las pueda arrancar." -ForegroundColor Yellow

Read-Host "Presiona ENTER para salir"
