<#
.SYNOPSIS
    Script automatizado para reparar archivos estructurales de Windows y componentes del sistema.
.DESCRIPTION
    Combina SFC (System File Checker) y DISM para arreglar problemas graves del SO 
    (pantallazos azules, Windows Update roto, interfaz corrupta) sin formatear.
#>
param()

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " REPARACIN ESTRUCTURAL DEL SO (SFC/DISM) " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Comprobar privilegios de Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Por favor, reinicia este script como Administrador."
    exit
}

Write-Host "`nFase 1: System File Checker (SFC)..." -ForegroundColor Yellow
Write-Host "Esto revisarǭ y repararǭ archivos base protegidos de Windows. Tardarǭ unos minutos."
sfc /scannow

Write-Host "`nFase 2: DISM (Deployment Image Servicing and Management)..." -ForegroundColor Yellow
Write-Host "Esto repararǭ la imagen de fondo (Almacn de componentes) desde los servidores de Microsoft."
Write-Host "Requiere conexin a Internet activa."
DISM /Online /Cleanup-Image /RestoreHealth

Write-Host "`nFase 3: Ejecutando SFC de nuevo por seguridad (Crucial tras DISM)..." -ForegroundColor Yellow
sfc /scannow

Write-Host "`nProceso completado. Si el sistema sigo fallando tras reiniciar, considera una reparacin In-Place o el anǭlisis del hardware." -ForegroundColor Green
Read-Host "Presiona ENTER para salir"
