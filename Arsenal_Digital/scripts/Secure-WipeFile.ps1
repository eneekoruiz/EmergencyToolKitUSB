<#
.SYNOPSIS
    Trituradora de archivos (Sobrescritura segura).
.DESCRIPTION
    Borra un archivo o carpeta sobrescribiendo su contenido mltiples veces
    para evitar la recuperacin forense, sin tener que formatear el disco completo.
    ATENCIN: Irreversible.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Target,
    
    [Parameter(Mandatory=$false)]
    [int]$Passes = 3
)

if (-not (Test-Path $Target)) {
    Write-Error "Ruta no encontrada: $Target"
    exit
}

Write-Host "=========================================" -ForegroundColor Red
Write-Host " TRITURADORA QUIRRGICA (SECURE WIPE) " -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Red
Write-Host "Objetivo: $Target"
Write-Host "Pasadas: $Passes"
Write-Host "-----------------------------------------"

$confirm = Read-Host "Escribe 'DESTRUIR' para sobrescribir y eliminar permanentemente este objetivo"
if ($confirm -cne 'DESTRUIR') {
    Write-Host "Operacin cancelada." -ForegroundColor Green
    exit
}

function Invoke-SecureWipeFile {
    param([string]$FilePath, [int]$PassCount)
    
    $fileInfo = New-Object System.IO.FileInfo($FilePath)
    $length = $fileInfo.Length
    
    for ($i = 1; $i -le $PassCount; $i++) {
        Write-Host "  -> Pasada $i de $PassCount en $FilePath..."
        # Llenar el archivo con ceros o bytes aleatorios
        $random = New-Object byte[] 4096
        
        $stream = [System.IO.File]::Open($FilePath, 'Open', 'Write')
        $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
        
        $bytesWritten = 0
        while ($bytesWritten -lt $length) {
            $rng.GetBytes($random)
            $writeCount = [Math]::Min($random.Length, $length - $bytesWritten)
            $stream.Write($random, 0, $writeCount)
            $bytesWritten += $writeCount
        }
        $stream.Close()
    }
    
    # Renombrar archivo antes de borrar (rompe rastro del MFT)
    $newName = [guid]::NewGuid().ToString()
    $newPath = Join-Path $fileInfo.DirectoryName $newName
    Rename-Item -Path $FilePath -NewName $newName -Force
    
    # Borrar
    Remove-Item -Path $newPath -Force
    Write-Host "  [OK] Destruido: $FilePath" -ForegroundColor Green
}

if (Test-Path $Target -PathType Container) {
    # Es un directorio, triturar todo recursivamente
    $files = Get-ChildItem -Path $Target -File -Recurse
    foreach ($file in $files) {
        Invoke-SecureWipeFile -FilePath $file.FullName -PassCount $Passes
    }
    Remove-Item -Path $Target -Recurse -Force
} else {
    # Es un archivo
    Invoke-SecureWipeFile -FilePath $Target -PassCount $Passes
}

Write-Host "`nOperacin Quirrgica completada." -ForegroundColor Yellow
