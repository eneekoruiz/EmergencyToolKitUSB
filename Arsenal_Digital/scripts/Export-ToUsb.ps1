[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$PrivacyDrive,
    [Parameter(Mandatory)] [string]$RescueDrive,
    [string]$Root
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Root) { $Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path }

function Assert-DriveRoot {
    param([string]$Drive)
    if ($Drive -match '^[A-Za-z]:$') { $Drive = "$Drive\" }
    $resolved = Resolve-Path $Drive
    if (-not $resolved.Path.EndsWith('\')) { return ($resolved.Path + '\') }
    return $resolved.Path
}

$privacyRoot = Assert-DriveRoot -Drive $PrivacyDrive
$rescueRoot = Assert-DriveRoot -Drive $RescueDrive

$copies = @(
    @{ Source = Join-Path $Root 'USB_PRIVACIDAD_TAILS'; Target = Join-Path $privacyRoot 'Arsenal_Digital\USB_PRIVACIDAD_TAILS' },
    @{ Source = Join-Path $Root '00_MANIFIESTOS'; Target = Join-Path $privacyRoot 'Arsenal_Digital\00_MANIFIESTOS' },
    @{ Source = Join-Path $Root 'USB_RESCATE_VENTOY'; Target = $rescueRoot },
    @{ Source = Join-Path $Root '00_MANIFIESTOS'; Target = Join-Path $rescueRoot 'docs\00_MANIFIESTOS' },
    @{ Source = Join-Path $Root 'scripts'; Target = Join-Path $rescueRoot 'tools\arsenal_scripts' }
)

foreach ($copy in $copies) {
    if (-not (Test-Path $copy.Source)) { continue }
    if ($PSCmdlet.ShouldProcess($copy.Target, "Copy from $($copy.Source)")) {
        New-Item -ItemType Directory -Force -Path $copy.Target | Out-Null
        robocopy $copy.Source $copy.Target /E /R:2 /W:2 /NFL /NDL /NP | Out-Null
        if ($LASTEXITCODE -gt 7) { throw "Robocopy failed with code $LASTEXITCODE for $($copy.Source)" }
    }
}

Write-Host 'Export complete. Re-run Verify-Arsenal.ps1 against the source before relying on payloads.'
