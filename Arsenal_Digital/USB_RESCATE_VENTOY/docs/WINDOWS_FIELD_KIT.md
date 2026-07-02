# Windows field kit

## Que incluye

- Sysinternals Suite: Autoruns, Process Explorer, Process Monitor, Sigcheck, TCPView, Disk2VHD, SDelete y utilidades de diagnostico Microsoft.
- Microsoft Safety Scanner x64 (`msert-x64.exe`): scanner antimalware portable firmado por Microsoft.

## Casos de uso

- Persistencia sospechosa: Autoruns y Sigcheck.
- Proceso raro o consumo anomalo: Process Explorer y Process Monitor.
- Conexion de red sospechosa: TCPView.
- Captura de equipo fisico a VHD: Disk2VHD.
- Borrado puntual: SDelete, solo con autorizacion.
- Segunda opinion antimalware: MSERT.

## Seguridad

- El script `Install-WindowsFieldKit.ps1` verifica firma Authenticode de Microsoft en MSERT y ejecutables clave de Sysinternals.
- MSERT expira a los 10 dias de descargarse; actualizalo antes de una salida importante.
- No ejecutes herramientas de escritura sobre discos que deban preservarse como evidencia.
