<#
.SYNOPSIS
    Copia perfiles de usuario a una carpeta de rescate no destructiva.
.DESCRIPTION
    Copia carpetas de usuario con robocopy /E hacia un destino timestamped. No usa /MIR para evitar borrar datos previos.
    Los datos de navegadores pueden contener secretos; exige confirmacion si se incluyen.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$Destination,
    [string[]]$Users,
    [switch]$IncludeBrowserSecrets,
    [switch]$WhatIfCopy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$usersDir = 'C:\Users'
$excludeDirs = @('Public', 'Default', 'Default User', 'All Users', 'Administrador')
$foldersToCopy = @('Desktop', 'Documents', 'Downloads', 'Favorites', 'Pictures', 'Videos', 'Music')

if (-not (Test-Path $Destination)) { New-Item -ItemType Directory -Force -Path $Destination | Out-Null }
$caseRoot = Join-Path $Destination ('ProfileBackup_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Force -Path $caseRoot | Out-Null
$logPath = Join-Path $caseRoot 'backup-manifest.jsonl'

function Write-Manifest {
    param([string]$Event, [hashtable]$Data)
    $record = [ordered]@{ timestamp = (Get-Date).ToUniversalTime().ToString('o'); event = $Event }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 6) | Add-Content -Path $logPath -Encoding UTF8
}

if ($IncludeBrowserSecrets) {
    Write-Host 'Los perfiles de navegador pueden contener cookies, tokens y bases Login Data.' -ForegroundColor Yellow
    $ack = Read-Host 'Escribe DESTINO-CIFRADO para confirmar que el destino esta cifrado o controlado'
    if ($ack -cne 'DESTINO-CIFRADO') { throw 'Confirmacion de destino cifrado/controlado fallida.' }
}

$availableUsers = Get-ChildItem -Path $usersDir -Directory -Force | Where-Object { $_.Name -notin $excludeDirs }
if ($Users) { $availableUsers = $availableUsers | Where-Object { $_.Name -in $Users } }
Write-Host "Destino de rescate: $caseRoot" -ForegroundColor Cyan

foreach ($user in $availableUsers) {
    $userDest = Join-Path $caseRoot $user.Name
    New-Item -ItemType Directory -Force -Path $userDest | Out-Null
    Write-Host "Procesando usuario: $($user.Name)" -ForegroundColor Yellow
    Write-Manifest -Event 'user_start' -Data @{ user = $user.Name; source = $user.FullName; destination = $userDest }

    foreach ($folder in $foldersToCopy) {
        $sourcePath = Join-Path $user.FullName $folder
        $destPath = Join-Path $userDest $folder
        if (Test-Path $sourcePath) {
            $args = @($sourcePath, $destPath, '/E', '/COPY:DAT', '/DCOPY:DAT', '/R:0', '/W:0', '/MT:8', '/XJ', '/NP', '/TEE', "/LOG+:$($logPath -replace '\.jsonl$', '.robocopy.log')")
            if ($WhatIfCopy) { $args += '/L' }
            robocopy @args | Out-Host
            $code = $LASTEXITCODE
            Write-Manifest -Event 'robocopy' -Data @{ user = $user.Name; folder = $folder; exitCode = $code }
            if ($code -gt 7) { Write-Warning "Robocopy reporto error $code en $sourcePath" }
        }
    }

    if ($IncludeBrowserSecrets) {
        $browserTargets = @(
            @{ Name = 'Chrome'; Path = Join-Path $user.FullName 'AppData\Local\Google\Chrome\User Data\Default'; Files = @('Bookmarks','Login Data','Cookies') },
            @{ Name = 'Edge'; Path = Join-Path $user.FullName 'AppData\Local\Microsoft\Edge\User Data\Default'; Files = @('Bookmarks','Login Data','Cookies') },
            @{ Name = 'Firefox'; Path = Join-Path $user.FullName 'AppData\Roaming\Mozilla\Firefox\Profiles'; Files = @() }
        )
        foreach ($browser in $browserTargets) {
            if (Test-Path $browser.Path) {
                $dest = Join-Path $userDest "AppData\$($browser.Name)"
                $args = @($browser.Path, $dest)
                if ($browser.Files.Count -gt 0) { $args += $browser.Files }
                $args += @('/E','/R:0','/W:0','/XJ','/NP')
                if ($WhatIfCopy) { $args += '/L' }
                robocopy @args | Out-Host
                Write-Manifest -Event 'browser_copy' -Data @{ user = $user.Name; browser = $browser.Name; exitCode = $LASTEXITCODE }
            }
        }
    }
}

Write-Host "Copia no destructiva completada: $caseRoot" -ForegroundColor Green
