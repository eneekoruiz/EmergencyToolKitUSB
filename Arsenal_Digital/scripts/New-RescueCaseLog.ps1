[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$CaseName,
    [string]$CaseRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $CaseRoot) { $CaseRoot = Join-Path (Resolve-Path (Join-Path $ScriptRoot '..')).Path 'USB_RESCATE_VENTOY\case_notes' }

$safeName = ($CaseName -replace '[^a-zA-Z0-9._-]', '_')
$path = Join-Path $CaseRoot ("{0}-{1}.md" -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $safeName)
New-Item -ItemType Directory -Force -Path $CaseRoot | Out-Null

@"
# Caso: $CaseName

## Identificacion

- Fecha UTC: $((Get-Date).ToUniversalTime().ToString('o'))
- Tecnico:
- Cliente / responsable:
- Autorizacion:
- Equipo:

## Estado inicial

- Sintoma:
- Riesgo percibido:
- Red aislada: si/no
- Discos retirados: si/no

## Inventario

Pega aqui salida de ``Get-DiskSnapshot.ps1`` o inventario desde SystemRescue.

## Acciones

| Hora UTC | Accion | Herramienta | Resultado | Hash / evidencia |
| --- | --- | --- | --- | --- |

## Cierre

- Datos recuperados:
- Reparacion realizada:
- Recomendacion:
- Pendiente:
"@ | Set-Content -Path $path -Encoding UTF8

Write-Host $path
