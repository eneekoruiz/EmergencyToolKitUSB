<#
.SYNOPSIS
    Borrado best-effort de archivos o carpetas.
.DESCRIPTION
    Sobrescribe contenido antes de borrar, pero no garantiza destruccion forense en SSD, NTFS journal,
    shadow copies, backups, indexadores o almacenamiento con wear leveling.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$Target,
    [ValidateRange(1,7)] [int]$Passes = 1,
    [switch]$AcknowledgeLimitations,
    [string]$AuditDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
if (-not $AuditDirectory) { $AuditDirectory = Join-Path $Root 'audit' }
New-Item -ItemType Directory -Force -Path $AuditDirectory | Out-Null
$AuditPath = Join-Path $AuditDirectory ('wipe-file-{0}.jsonl' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Write-Audit {
    param([string]$Event, [hashtable]$Data)
    $record = [ordered]@{ timestamp = (Get-Date).ToUniversalTime().ToString('o'); event = $Event }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 6) | Add-Content -Path $AuditPath -Encoding UTF8
}

function Invoke-BestEffortWipeFile {
    param([string]$FilePath, [int]$PassCount)
    $fileInfo = Get-Item -LiteralPath $FilePath -Force
    if ($fileInfo.Length -eq 0) { Remove-Item -LiteralPath $FilePath -Force; return }

    for ($i = 1; $i -le $PassCount; $i++) {
        Write-Host "  -> Pasada $i/${PassCount}: $FilePath"
        $buffer = New-Object byte[] 1048576
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $stream = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try {
            $remaining = $fileInfo.Length
            while ($remaining -gt 0) {
                $rng.GetBytes($buffer)
                $writeCount = [Math]::Min($buffer.Length, $remaining)
                $stream.Write($buffer, 0, $writeCount)
                $remaining -= $writeCount
            }
            $stream.Flush($true)
        }
        finally {
            $stream.Dispose()
            $rng.Dispose()
        }
    }

    $newName = [guid]::NewGuid().ToString('N')
    Rename-Item -LiteralPath $FilePath -NewName $newName -Force
    $newPath = Join-Path $fileInfo.DirectoryName $newName
    Remove-Item -LiteralPath $newPath -Force
    Write-Audit -Event 'file_wiped' -Data @{ path = $FilePath; bytes = $fileInfo.Length; passes = $PassCount }
}

$resolved = Resolve-Path -LiteralPath $Target -ErrorAction Stop
Write-Host '=========================================' -ForegroundColor Red
Write-Host ' BORRADO BEST-EFFORT DE ARCHIVOS' -ForegroundColor Red
Write-Host '=========================================' -ForegroundColor Red
Write-Host "Objetivo: $($resolved.Path)"
Write-Host "Pasadas: $Passes"
Write-Host 'LIMITACION: no garantiza destruccion forense en SSD, shadow copies, backups, journal NTFS o almacenamiento remoto.' -ForegroundColor Yellow

if (-not $AcknowledgeLimitations) {
    $ack = Read-Host 'Escribe ENTIENDO-LIMITACIONES para continuar'
    if ($ack -cne 'ENTIENDO-LIMITACIONES') { throw 'Limitaciones no aceptadas. Abortado.' }
}
$confirm = Read-Host 'Escribe DESTRUIR para sobrescribir y eliminar permanentemente el objetivo'
if ($confirm -cne 'DESTRUIR') { throw 'Confirmacion incorrecta. Abortado.' }

$item = Get-Item -LiteralPath $resolved.Path -Force
if ($item.PSIsContainer) {
    $files = Get-ChildItem -LiteralPath $item.FullName -File -Recurse -Force
    foreach ($file in $files) {
        if ($PSCmdlet.ShouldProcess($file.FullName, 'overwrite and delete')) {
            Invoke-BestEffortWipeFile -FilePath $file.FullName -PassCount $Passes
        }
    }
    if ($PSCmdlet.ShouldProcess($item.FullName, 'remove directory')) {
        Remove-Item -LiteralPath $item.FullName -Recurse -Force
    }
} else {
    if ($PSCmdlet.ShouldProcess($item.FullName, 'overwrite and delete')) {
        Invoke-BestEffortWipeFile -FilePath $item.FullName -PassCount $Passes
    }
}

Write-Host 'Borrado best-effort completado.' -ForegroundColor Green

