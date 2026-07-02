<#
.SYNOPSIS
    Compatibilidad: redirige al instalador verificado de herramientas Windows.
.DESCRIPTION
    Este script queda como alias seguro. La descarga real se hace con Install-WindowsFieldKit.ps1,
    que genera hashes y verifica firmas Authenticode de Microsoft.
#>
[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$installer = Join-Path $ScriptRoot 'Install-WindowsFieldKit.ps1'
if (-not (Test-Path $installer)) { throw "No se encuentra $installer" }

Write-Warning 'Download-EmergencyTools.ps1 esta deprecado. Usando Install-WindowsFieldKit.ps1 con verificacion de firmas.'
& $installer @PSBoundParameters
