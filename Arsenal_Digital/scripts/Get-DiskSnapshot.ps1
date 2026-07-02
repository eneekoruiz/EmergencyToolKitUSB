[CmdletBinding()]
param(
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path (Resolve-Path (Join-Path $ScriptRoot '..')).Path 'audit' }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$out = Join-Path $OutputDirectory "disk-snapshot-$stamp.json"

$snapshot = [ordered]@{
    timestamp = (Get-Date).ToUniversalTime().ToString('o')
    computer = $env:COMPUTERNAME
    disks = Get-Disk | Select-Object Number, FriendlyName, SerialNumber, HealthStatus, OperationalStatus, PartitionStyle, Size, BusType, IsBoot, IsSystem, IsOffline, IsReadOnly
    physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, SerialNumber, MediaType, HealthStatus, OperationalStatus, Size
    volumes = Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, HealthStatus, OperationalStatus, Size, SizeRemaining
    partitions = Get-Partition | Select-Object DiskNumber, PartitionNumber, DriveLetter, Type, GptType, Size, Offset
}

$snapshot | ConvertTo-Json -Depth 6 | Set-Content -Path $out -Encoding UTF8
Write-Host $out
