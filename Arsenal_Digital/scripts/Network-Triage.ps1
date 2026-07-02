[CmdletBinding()]
param(
    [string]$Target = '1.1.1.1',
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path (Resolve-Path (Join-Path $ScriptRoot '..')).Path 'audit' }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$out = Join-Path $OutputDirectory "network-triage-$stamp.txt"

@(
    "Timestamp UTC: $((Get-Date).ToUniversalTime().ToString('o'))"
    "Computer: $env:COMPUTERNAME"
    ''
    '== IP Configuration =='
    (Get-NetIPConfiguration | Out-String)
    '== Routes =='
    (Get-NetRoute | Sort-Object RouteMetric | Out-String)
    '== DNS Client Servers =='
    (Get-DnsClientServerAddress | Out-String)
    "== Ping $Target =="
    (Test-Connection -ComputerName $Target -Count 4 | Out-String)
    "== TCP 443 $Target =="
    (Test-NetConnection -ComputerName $Target -Port 443 | Out-String)
) | Set-Content -Path $out -Encoding UTF8

Write-Host $out
