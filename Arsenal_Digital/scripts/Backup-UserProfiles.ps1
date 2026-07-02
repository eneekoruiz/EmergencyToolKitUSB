<#
.SYNOPSIS
    Realiza una copia de seguridad rápida de los perfiles de usuario.
.DESCRIPTION
    Extrae Desktop, Documents, Downloads, Favorites, Pictures, Videos y datos de navegadores (Chrome, Firefox, Edge) del usuario especificado o de todos los usuarios en C:\Users hacia el destino.
    Ideal para un escenario de "disco moribundo" donde necesitas sacar los datos vitales rápidamente. Usa robocopy con reintentos mínimos para no quedarse atascado en sectores defectuosos.
.PARAMETER Destination
    Ruta de destino (tu disco duro externo o USB).
.EXAMPLE
    .\Backup-UserProfiles.ps1 -Destination "E:\Rescates\Cliente1"
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Destination
)

$usersDir = "C:\Users"
$excludeDirs = @("Public", "Default", "Default User", "All Users", "Administrador")
$foldersToCopy = @("Desktop", "Documents", "Downloads", "Favorites", "Pictures", "Videos", "Music")

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

Write-Host "Iniciando copia de seguridad rápida de perfiles en $usersDir hacia $Destination" -ForegroundColor Cyan

$users = Get-ChildItem -Path $usersDir -Directory | Where-Object { $_.Name -notin $excludeDirs }

foreach ($user in $users) {
    $userDest = Join-Path $Destination $user.Name
    if (-not (Test-Path $userDest)) { New-Item -ItemType Directory -Path $userDest | Out-Null }
    
    Write-Host "Procesando usuario: $($user.Name)" -ForegroundColor Yellow
    
    foreach ($folder in $foldersToCopy) {
        $sourcePath = Join-Path $user.FullName $folder
        $destPath = Join-Path $userDest $folder
        
        if (Test-Path $sourcePath) {
            Write-Host " Copiando $folder..."
            # /MIR (espejo), /R:0 (0 reintentos si falla lectura), /W:0 (0 segundos espera), /MT:8 (multihilo), /NDL /NFL (menos verbosidad)
            robocopy $sourcePath $destPath /MIR /R:0 /W:0 /MT:8 /NDL /NFL /NJH /NJS
        }
    }
    
    # Navegadores
    Write-Host " Copiando datos de Navegadores (Marcadores, Contraseñas)..."
    
    # Chrome
    $chromePath = "$($user.FullName)\AppData\Local\Google\Chrome\User Data\Default"
    if (Test-Path $chromePath) {
        robocopy $chromePath "$userDest\AppData\Chrome" "Bookmarks" "Login Data" /R:0 /W:0 /NDL /NFL /NJH /NJS
    }
    
    # Edge
    $edgePath = "$($user.FullName)\AppData\Local\Microsoft\Edge\User Data\Default"
    if (Test-Path $edgePath) {
        robocopy $edgePath "$userDest\AppData\Edge" "Bookmarks" "Login Data" /R:0 /W:0 /NDL /NFL /NJH /NJS
    }
    
    # Firefox (busca el perfil default)
    $ffPath = "$($user.FullName)\AppData\Roaming\Mozilla\Firefox\Profiles"
    if (Test-Path $ffPath) {
        robocopy $ffPath "$userDest\AppData\Firefox" /E /R:0 /W:0 /NDL /NFL /NJH /NJS
    }
}

Write-Host "Copia de seguridad completada." -ForegroundColor Green
