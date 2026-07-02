<#
.SYNOPSIS
    Actualiza y valida el Arsenal Digital.
.DESCRIPTION
    Ejecuta descargas verificadas, refresca herramientas Windows caducables, expande payloads auxiliares,
    verifica hashes y genera un informe Markdown de mantenimiento.
#>
[CmdletBinding()]
param(
    [switch]$RefreshWindowsFieldKit,
    [switch]$RefreshAllPayloads,
    [switch]$SkipDownloads,
    [string]$ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
if (-not $ReportPath) { $ReportPath = Join-Path $Root ('UPDATE_REPORT_{0}.md' -f (Get-Date -Format 'yyyyMMdd-HHmmss')) }

$steps = New-Object System.Collections.Generic.List[object]
function Add-Step {
    param([string]$Name, [string]$Status, [string]$Detail)
    $steps.Add([pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail }) | Out-Null
}

function Invoke-Step {
    param([string]$Name, [scriptblock]$Action)
    try {
        & $Action
        Add-Step -Name $Name -Status 'OK' -Detail ''
    } catch {
        Add-Step -Name $Name -Status 'FAIL' -Detail $_.Exception.Message
        throw
    }
}

if (-not $SkipDownloads) {
    $buildArgs = @{}
    if ($RefreshAllPayloads) { $buildArgs.Force = $true }
    Invoke-Step -Name 'Payload manifest download/verify' -Action { & (Join-Path $ScriptRoot 'Build-Arsenal.ps1') @buildArgs }

    if ($RefreshWindowsFieldKit) {
        Invoke-Step -Name 'Windows field kit refresh' -Action { & (Join-Path $ScriptRoot 'Install-WindowsFieldKit.ps1') -Force }
    }
}

Invoke-Step -Name 'Hardware payload expansion' -Action { & (Join-Path $ScriptRoot 'Expand-HardwarePayloads.ps1') -Force }
Invoke-Step -Name 'SHA-256 sidecar verification' -Action { & (Join-Path $ScriptRoot 'Verify-Arsenal.ps1') }
Invoke-Step -Name 'Operational validation' -Action { & (Join-Path $ScriptRoot 'Validate-Arsenal.ps1') }

$msertPath = Join-Path $Root 'USB_RESCATE_VENTOY\tools\windows\msert-x64.exe'
$msertAge = $null
if (Test-Path $msertPath) { $msertAge = [math]::Round(((Get-Date) - (Get-Item $msertPath).LastWriteTime).TotalDays, 1) }

$payloadBytes = (Get-ChildItem -Path $Root -Recurse -File | Measure-Object -Property Length -Sum).Sum
$payloadGb = [math]::Round($payloadBytes / 1GB, 2)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Arsenal Digital - Update Report') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('- Fecha UTC: ' + (Get-Date).ToUniversalTime().ToString('o')) | Out-Null
$lines.Add('- Root: `' + $Root + '`') | Out-Null
$lines.Add('- Tamano total aproximado: ' + $payloadGb + ' GB') | Out-Null
$lines.Add('- MSERT age days: ' + $msertAge) | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Steps') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| Step | Status | Detail |') | Out-Null
$lines.Add('| --- | --- | --- |') | Out-Null
foreach ($step in $steps) {
    $detail = if ($step.Detail) { $step.Detail.Replace('|','/') } else { '' }
    $lines.Add('| ' + $step.Name + ' | ' + $step.Status + ' | ' + $detail + ' |') | Out-Null
}
$lines.Add('') | Out-Null
$lines.Add('## Nota operativa') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('- Si MSERT supera 10 dias, ejecuta `Update-Arsenal.ps1 -RefreshWindowsFieldKit` antes de una intervencion.') | Out-Null
$lines | Set-Content -Path $ReportPath -Encoding UTF8
Write-Host $ReportPath
