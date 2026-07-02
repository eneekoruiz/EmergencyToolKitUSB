<#
.SYNOPSIS
    Helper para obtener ISOs oficiales de Windows.
.DESCRIPTION
    Por licencia no se incluyen ISOs de Windows. Este helper imprime rutas oficiales y recuerda usar
    Rufus/Fido o Media Creation Tool desde Microsoft. No abre navegador automaticamente salvo que se pida.
#>
[CmdletBinding()]
param(
    [switch]$OpenOfficialPage
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$officialUrl = 'https://www.microsoft.com/software-download/'
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
$rufusPath = Join-Path $Root 'USB_RESCATE_VENTOY\tools\windows\rufus-4.15.exe'
$windowsIsoDir = Join-Path $Root 'USB_RESCATE_VENTOY\ISO\05_installers\windows'

Write-Host '==========================================' -ForegroundColor Cyan
Write-Host ' WINDOWS ISO ACQUISITION HELPER' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan
Write-Host 'Official Microsoft download page:'
Write-Host $officialUrl -ForegroundColor Yellow
Write-Host ''
Write-Host 'Recommended workflow:'
Write-Host '1. Use Microsoft Media Creation Tool or Rufus download mode.'
Write-Host '2. Save Windows ISOs under:'
Write-Host "   $windowsIsoDir" -ForegroundColor Yellow
Write-Host '3. Record source URL, date, edition, language and SHA-256 in a case note.'
Write-Host '4. Do not upload Windows ISOs to GitHub.'
Write-Host ''
if (Test-Path $rufusPath) { Write-Host "Rufus present: $rufusPath" -ForegroundColor Green }
else { Write-Warning "Rufus not found at expected path: $rufusPath" }

if ($OpenOfficialPage) { Start-Process $officialUrl }
