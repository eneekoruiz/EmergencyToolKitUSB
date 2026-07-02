<#
.SYNOPSIS
    Valida consistencia operativa del Arsenal Digital.
.DESCRIPTION
    Comprueba parseo de scripts, presencia de payloads criticos, sidecars SHA-256, edad de MSERT,
    y existencia de playbooks/protocolos minimos. No modifica archivos.
#>
[CmdletBinding()]
param(
    [string]$Root
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Root) { $Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path }

$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
function Add-Failure([string]$Message) { $failures.Add($Message) | Out-Null }
function Add-Warning([string]$Message) { $warnings.Add($Message) | Out-Null }

Get-ChildItem -Path (Join-Path $Root 'scripts') -Filter '*.ps1' | ForEach-Object {
    $scriptFile = $_
    try { [scriptblock]::Create((Get-Content -Raw $scriptFile.FullName)) | Out-Null }
    catch { Add-Failure "PowerShell parse failed: $($scriptFile.Name): $($_.Exception.Message)" }
}

$critical = @(
    'USB_PRIVACIDAD_TAILS\images\tails-amd64-7.9.1.img',
    'USB_RESCATE_VENTOY\ISO\01_rescue\systemrescue-13.01-amd64.iso',
    'USB_RESCATE_VENTOY\ISO\03_imaging\rescuezilla-2.6.2-64bit.resolute.iso',
    'USB_RESCATE_VENTOY\ISO\04_hardware\grub-memtest.iso',
    'USB_RESCATE_VENTOY\ISO\05_installers\ubuntu-26.04-desktop-amd64.iso',
    'USB_RESCATE_VENTOY\ISO\05_installers\ubuntu-26.04-live-server-amd64.iso',
    'USB_RESCATE_VENTOY\ISO\06_wipe\shredos-2025.11_30_x86-64_v0.41_20260520_lite.iso',
    'USB_RESCATE_VENTOY\tools\windows\msert-x64.exe',
    'USB_RESCATE_VENTOY\tools\windows\SysinternalsSuite.zip',
    'USB_RESCATE_VENTOY\tools\windows\data-recovery\testdisk-7.2.win64.zip'
)
foreach ($rel in $critical) {
    $path = Join-Path $Root $rel
    if (-not (Test-Path $path)) { Add-Failure "Missing critical payload: $rel"; continue }
    if (-not (Test-Path "$path.sha256")) { Add-Failure "Missing SHA-256 sidecar: $rel" }
}

$msert = Join-Path $Root 'USB_RESCATE_VENTOY\tools\windows\msert-x64.exe'
if (Test-Path $msert) {
    $age = ((Get-Date) - (Get-Item $msert).LastWriteTime).TotalDays
    if ($age -gt 10) { Add-Warning "MSERT older than 10 days: $([math]::Round($age,1)) days" }
    $sig = Get-AuthenticodeSignature -FilePath $msert
    if ($sig.Status -ne 'Valid' -or -not $sig.SignerCertificate -or $sig.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
        Add-Failure "MSERT signature invalid: $($sig.Status)"
    }
}

$requiredDocs = @(
    'README_OPERATIVO.md',
    'TESTED_BOOT_MATRIX.md',
    'OPERATIONAL_ACCEPTANCE_CHECKLIST.md',
    'USB_RESCATE_VENTOY\docs\DATA_RECOVERY.md',
    'USB_RESCATE_VENTOY\docs\WINDOWS_FIELD_KIT.md',
    'SECRETS\PROTOCOLO_BOVEDA.md'
)
foreach ($rel in $requiredDocs) {
    if (-not (Test-Path (Join-Path $Root $rel))) { Add-Failure "Missing required doc: $rel" }
}

if ($warnings.Count -gt 0) { $warnings | ForEach-Object { Write-Warning $_ } }
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 2
}
Write-Host 'Operational validation OK.'

