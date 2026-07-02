[CmdletBinding()]
param(
    [string]$HardwareIsoDir,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
if (-not $HardwareIsoDir) { $HardwareIsoDir = Join-Path $Root 'USB_RESCATE_VENTOY\ISO\04_hardware' }

$zip = Get-ChildItem -Path $HardwareIsoDir -Filter 'mt86plus_*_x86_64.grub.iso.zip' -File | Select-Object -First 1
if (-not $zip) { throw "Memtest86+ ZIP not found in $HardwareIsoDir" }

$temp = Join-Path $HardwareIsoDir '_extract_memtest'
if (Test-Path $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
New-Item -ItemType Directory -Force -Path $temp | Out-Null
Expand-Archive -Path $zip.FullName -DestinationPath $temp -Force

$iso = Get-ChildItem -Path $temp -Filter '*.iso' -Recurse -File | Select-Object -First 1
if (-not $iso) { throw "No ISO found inside $($zip.Name)" }
$target = Join-Path $HardwareIsoDir $iso.Name
if ((Test-Path $target) -and -not $Force) {
    Write-Host "Already extracted: $target"
} else {
    Move-Item -Force -LiteralPath $iso.FullName -Destination $target
}
Remove-Item -LiteralPath $temp -Recurse -Force

$hash = (Get-FileHash -Algorithm SHA256 -Path $target).Hash.ToLowerInvariant()
"$hash *$(Split-Path -Leaf $target)" | Set-Content -Path "$target.sha256" -Encoding ASCII
Write-Host "Memtest86+ ISO ready: $target"
