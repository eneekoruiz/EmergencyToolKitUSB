[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Target = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Arsenal_Digital'),
    [string]$Source
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Source) { $Source = (Resolve-Path (Join-Path $ScriptRoot '..')).Path }

if ($PSCmdlet.ShouldProcess($Target, 'Create or update Arsenal_Digital folder')) {
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    robocopy $Source $Target /E /R:2 /W:2 /NFL /NDL /NP | Out-Null
    if ($LASTEXITCODE -gt 7) { throw "Robocopy failed with code $LASTEXITCODE" }
}

Write-Host $Target
