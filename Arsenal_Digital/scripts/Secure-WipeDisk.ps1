<#
.SYNOPSIS
    Borrado seguro de un disco físico (Wipe).
.DESCRIPTION
    Peligro: Este script limpiará completamente un disco sobrescribiendo con ceros mediante DiskPart (clean all).
    ESTO ES IRREVERSIBLE. Se solicitará confirmación varias veces.
#>
param()

Write-Host "=============================================" -ForegroundColor Red
Write-Host " PELIGRO: HERRAMIENTA DE BORRADO SEGURO" -ForegroundColor Red
Write-Host "=============================================" -ForegroundColor Red
Write-Host "Este script borrará TODOS LOS DATOS del disco seleccionado."

# Listar discos
$diskScript = "list disk"
$diskScript | diskpart | Select-String "Disco " | Write-Host

$diskNumber = Read-Host "Introduce el número del disco a borrar (ej. 1, 2, 3... o 'Q' para salir)"

if ($diskNumber -eq 'Q' -or $diskNumber -eq 'q') {
    Write-Host "Operación cancelada." -ForegroundColor Green
    exit
}

$confirm1 = Read-Host "¿ESTÁS TOTALMENTE SEGURO de querer borrar el Disco $diskNumber? (S/N)"
if ($confirm1 -notmatch '^[Ss]$') { exit }

$confirm2 = Read-Host "Última advertencia. Se destruirán particiones y datos. Escribe 'BORRAR' para continuar"
if ($confirm2 -cne 'BORRAR') { exit }

Write-Host "Iniciando 'clean all' en el Disco $diskNumber. Esto tomará mucho tiempo (horas dependiendo del tamaño)..." -ForegroundColor Yellow

$dpScript = @"
select disk $diskNumber
clean all
create partition primary
format fs=ntfs quick label="WIPED"
assign
"@

$dpScript | diskpart

Write-Host "Borrado seguro completado." -ForegroundColor Green
