[CmdletBinding()]
param(
    [string]$Root
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Root) { $Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path }

$shaFiles = Get-ChildItem -Path $Root -Recurse -Filter '*.sha256'
if (-not $shaFiles) {
    Write-Warning "No .sha256 files found under $Root"
    exit 1
}

$failures = @()
foreach ($shaFile in $shaFiles) {
    $line = Get-Content -Path $shaFile.FullName -TotalCount 1
    if ($line -notmatch '^(?<hash>[a-fA-F0-9]{64})\s+\*?(?<file>.+)$') {
        $failures += "Invalid sha256 sidecar: $($shaFile.FullName)"
        continue
    }

    $target = Join-Path $shaFile.DirectoryName $Matches.file
    if (-not (Test-Path $target)) {
        $failures += "Missing file for sidecar: $target"
        continue
    }

    $actual = (Get-FileHash -Algorithm SHA256 -Path $target).Hash.ToLowerInvariant()
    $expected = $Matches.hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        $failures += "Hash mismatch: $target expected $expected actual $actual"
    } else {
        Write-Host "OK $target"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 2
}

Write-Host 'All SHA-256 sidecars verified.'
