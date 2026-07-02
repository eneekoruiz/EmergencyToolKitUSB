<#
.SYNOPSIS
    Realiza diagnstico de hardware bsico (Discos y Memoria).
.DESCRIPTION
    Revisa el estado S.M.A.R.T de los discos fsicos, la degradacin de la batera (en portǭtiles) 
    y busca errores de memoria reportados a Windows.
#>

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " DIAGNSTICO RPIDO DE HARDWARE " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

Write-Host "`n[1] ESTADO DE LOS DISCOS (S.M.A.R.T)" -ForegroundColor Yellow
try {
    # Requiere PowerShell 5.1+ y permisos de Administrador
    $disks = Get-PhysicalDisk
    foreach ($disk in $disks) {
        $health = $disk.HealthStatus
        $opStatus = $disk.OperationalStatus
        $color = if ($health -eq 'Healthy') { 'Green' } else { 'Red' }
        Write-Host "Disco $($disk.DeviceId): $($disk.Model) - Estado: $health ($opStatus)" -ForegroundColor $color
    }
} catch {
    Write-Host "No se pudo consultar Get-PhysicalDisk. Intenta usar CMD: wmic diskdrive get model,status" -ForegroundColor Red
}

Write-Host "`n[2] BATERA (Si aplica)" -ForegroundColor Yellow
try {
    $battery = Get-WmiObject Win32_Battery -ErrorAction Stop
    if ($battery) {
        Write-Host "Batera detectada. Estado de carga: $($battery.EstimatedChargeRemaining)%"
    } else {
        Write-Host "No se detect batera (Equipo de sobremesa)."
    }
} catch {
    Write-Host "Sin informacin de batera."
}

Write-Host "`n[3] MEMORIA RAM" -ForegroundColor Yellow
$ram = Get-WmiObject Win32_PhysicalMemory
$totalGB = 0
foreach ($stick in $ram) {
    $totalGB += ($stick.Capacity / 1GB)
    Write-Host "Mdulo en $($stick.DeviceLocator): $([math]::Round($stick.Capacity / 1GB, 2)) GB - Velocidad: $($stick.Speed) MHz"
}
Write-Host "Total RAM: $totalGB GB"

Write-Host "`nDiagnstico bsico completado. Si notas inestabilidad extrema, usa Memtest86+ desde Ventoy." -ForegroundColor Cyan
