# README OPERATIVO - Arsenal Digital

## Que es

`Arsenal_Digital` es la carpeta maestra para construir y auditar dos USB independientes: uno de privacidad basado en Tails y otro de rescate basado en Ventoy.

## Caso de uso extremo

- Equipo comprometido o no confiable: arrancar Tails desde el USB dedicado.
- Equipo que no arranca: usar Ventoy con SystemRescue, Rescuezilla, GParted o Memtest86+.
- Disco con posible fallo: inventariar primero, clonar despues, reparar al final.
- Incidente de campo sin Internet: usar las imagenes ya descargadas y los runbooks incluidos.

## Arranque critico

1. No conectes ambos USB a la vez salvo que sea necesario.
2. Si hay sospecha de malware, no abras archivos del equipo afectado desde Windows anfitrion.
3. Para privacidad, arranca solo el USB Tails dedicado.
4. Para rescate, arranca el USB Ventoy y elige la ISO segun el problema.
5. Documenta cada accion en `USB_RESCATE_VENTOY/case_notes`.

## Protocolo de seguridad

- Verifica hashes antes de mover o grabar imagenes.
- Mantén Tails con persistencia cifrada y passphrase larga.
- Guarda llaves, bases KeePassXC y claves de recuperacion fuera del USB de rescate.
- No mezcles identidad real, administracion de clientes y anonimato en la misma sesion Tails.
- Antes de operar sobre discos, crea inventario y, si hay datos criticos, imagen forense o clon.

## Scripts principales

- `scripts/Build-Arsenal.ps1`: descarga y verifica segun manifiesto.
- `scripts/Verify-Arsenal.ps1`: revalida todos los `.sha256`.
- `scripts/Export-ToUsb.ps1`: copia estructura a unidades USB montadas.
- `scripts/Get-DiskSnapshot.ps1`: inventario no destructivo de discos Windows.
- `scripts/New-RescueCaseLog.ps1`: abre una bitacora de caso.

