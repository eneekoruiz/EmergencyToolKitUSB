<#
.SYNOPSIS
    Borrado seguro controlado de un disco fisico.
.DESCRIPTION
    Ejecuta DiskPart clean all solo sobre un disco no protegido, con confirmacion por numero de serie,
    log de auditoria y modo de simulacion. Por defecto NO crea particiones despues del borrado.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [int]$DiskNumber,
    [switch]$Reinitialize,
    [string]$AuditDirectory,
    [switch]$ListOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
if (-not $AuditDirectory) { $AuditDirectory = Join-Path $Root 'audit' }
New-Item -ItemType Directory -Force -Path $AuditDirectory | Out-Null
$AuditPath = Join-Path $AuditDirectory ('wipe-disk-{0}.jsonl' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Write-Audit {
    param([string]$Event, [hashtable]$Data)
    $record = [ordered]@{ timestamp = (Get-Date).ToUniversalTime().ToString('o'); event = $Event }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 6) | Add-Content -Path $AuditPath -Encoding UTF8
}

function Show-Disks {
    Get-Disk | Sort-Object Number | Select-Object Number, FriendlyName, SerialNumber, BusType, PartitionStyle,
        @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}}, IsBoot, IsSystem, IsOffline, IsReadOnly | Format-Table -AutoSize
}

Write-Host '=============================================' -ForegroundColor Red
Write-Host ' PELIGRO: BORRADO COMPLETO DE DISCO' -ForegroundColor Red
Write-Host '=============================================' -ForegroundColor Red
Write-Host 'Por defecto solo borra. Usa -Reinitialize si quieres crear NTFS WIPED despues.' -ForegroundColor Yellow
Show-Disks

if ($ListOnly) { return }
if (-not $PSBoundParameters.ContainsKey('DiskNumber')) {
    $inputDisk = Read-Host "Numero de disco a borrar, o Q para salir"
    if ($inputDisk -match '^[Qq]$') { Write-Host 'Operacion cancelada.'; return }
    if ($inputDisk -notmatch '^\d+$') { throw 'Numero de disco invalido.' }
    $DiskNumber = [int]$inputDisk
}

$disk = Get-Disk -Number $DiskNumber -ErrorAction Stop
if ($disk.IsBoot -or $disk.IsSystem) { throw "Proteccion activada: el disco $DiskNumber es Boot/System." }
if ($disk.BusType -eq 'RAID') { Write-Warning 'Disco bajo RAID/controladora: confirma fuera de banda que es el objetivo correcto.' }

$serial = if ($disk.SerialNumber) { $disk.SerialNumber.Trim() } else { 'SIN_SERIAL' }
$sizeGb = [math]::Round($disk.Size / 1GB, 2)
Write-Host "Objetivo: Disk $DiskNumber | $($disk.FriendlyName) | $sizeGb GB | Serial: $serial" -ForegroundColor Yellow
Write-Host 'Esto es irreversible. En SSD/NVMe, preferir Secure Erase del fabricante si hay requisitos forenses.' -ForegroundColor Yellow

$confirmSerial = Read-Host "Escribe el numero de serie exacto para confirmar ($serial)"
if ($confirmSerial -ne $serial) { throw 'Confirmacion de serial fallida. Abortado.' }
$confirmPhrase = Read-Host "Escribe BORRAR-DISCO-$DiskNumber para continuar"
if ($confirmPhrase -cne "BORRAR-DISCO-$DiskNumber") { throw 'Frase de confirmacion incorrecta. Abortado.' }

Write-Audit -Event 'wipe_confirmed' -Data @{ diskNumber = $DiskNumber; serial = $serial; sizeGB = $sizeGb; reinitialize = [bool]$Reinitialize }

$commands = @(
    "select disk $DiskNumber",
    'detail disk',
    'clean all'
)
if ($Reinitialize) {
    $commands += @('create partition primary', 'format fs=ntfs quick label="WIPED"', 'assign')
}
$dpScript = ($commands -join [Environment]::NewLine) + [Environment]::NewLine

if ($PSCmdlet.ShouldProcess("Disk $DiskNumber / $serial", 'diskpart clean all')) {
    Write-Host "Iniciando clean all en Disk $DiskNumber. Puede tardar horas." -ForegroundColor Red
    $dpScript | diskpart | Tee-Object -FilePath (Join-Path $AuditDirectory ('diskpart-wipe-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss')))
    Write-Audit -Event 'wipe_completed' -Data @{ diskNumber = $DiskNumber; serial = $serial }
    Write-Host 'Borrado completado.' -ForegroundColor Green
}
