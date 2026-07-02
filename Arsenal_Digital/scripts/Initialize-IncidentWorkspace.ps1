<#
.SYNOPSIS
    Inicializa una estructura de carpetas profesional para una nueva intervencin.
.DESCRIPTION
    Evita que mezcles archivos, evidencias y volcados de clientes distintos en el USB.
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$CaseName
)

if ([string]::IsNullOrWhiteSpace($CaseName)) {
    $CaseName = Read-Host "Introduce el nombre del Caso o Cliente (ej. ACME_Ransomware)"
}

# Limpiar nombre para evitar caracteres ilegales en la ruta
$safeName = $CaseName -replace '[^a-zA-Z0-9_\-]', '_'
$dateStr = Get-Date -Format "yyyyMMdd"
$folderName = "${dateStr}_${safeName}"

# Asumimos que los casos se guardan en la raz del USB en la carpeta 'CASOS'
$usbRoot = (Split-Path -Parent $MyInvocation.MyCommand.Definition) | Split-Path -Parent
$casesRoot = Join-Path $usbRoot "CASOS"

if (-not (Test-Path $casesRoot)) { New-Item -ItemType Directory -Path $casesRoot | Out-Null }

$casePath = Join-Path $casesRoot $folderName

if (Test-Path $casePath) {
    Write-Warning "La carpeta del caso $folderName ya existe."
    exit
}

New-Item -ItemType Directory -Path $casePath | Out-Null
New-Item -ItemType Directory -Path (Join-Path $casePath "1_Evidencias") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $casePath "2_Logs_Triaje") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $casePath "3_Backups") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $casePath "4_Reportes") | Out-Null

$readmeContent = @"
# Bitcora de Caso: $safeName
Fecha de inicio: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Notas
- 
"@

Set-Content -Path (Join-Path $casePath "NOTAS.md") -Value $readmeContent

Write-Host "Espacio de trabajo creado con xito en:" -ForegroundColor Green
Write-Host $casePath -ForegroundColor Yellow
Invoke-Item $casePath
