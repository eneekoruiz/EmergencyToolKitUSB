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
- `scripts/Backup-UserProfiles.ps1`: backup agresivo de perfiles de usuario.
- `scripts/Secure-WipeDisk.ps1`: borrado seguro de discos físicos con DiskPart.
- `scripts/Download-EmergencyTools.ps1`: automatiza descarga de Sysinternals (evitando falsos positivos).
- `scripts/Get-WindowsISO.ps1`: instrucciones/helpers para obtener ISOs de Windows limpias.
- `scripts/Backup-WindowsDrivers.ps1`: extrae todos los drivers del PC (ideal antes de formatear).
- `scripts/Collect-TriageData.ps1`: (NUEVO) recolección en vivo de procesos, red y servicios a CSV.
- `scripts/Test-HardwareHealth.ps1`: (NUEVO) diagnóstico S.M.A.R.T de discos y memoria vía WMI.
- `scripts/Initialize-IncidentWorkspace.ps1`: (NUEVO) andamiaje rápido de carpetas estructuradas para un caso.

## Nuevos Módulos Integrados

- **`PLAYBOOKS/`**: Guías rápidas y cheatsheets de actuación (Linux, Redes, Windows Forense, Ransomware, BitLocker, RAW, Bypass Contraseñas, TCPDump). Ideal para consultar bajo presión.
- **`SECRETS/`**: Protocolo de bóveda segura. Un lugar dedicado para gestionar contraseñas temporales mediante KeePassXC o VeraCrypt sin comprometer texto plano.
- **`INVENTARIO_HARDWARE.md`**: Checklist físico de cables, adaptadores y herramientas necesarias antes de cualquier salida a campo.
- **`USB_AUDITORIA_KALI/`**: (Opcional/Aislado) Estructura preparada para alojar entornos ofensivos, exploits y diccionarios, manteniéndolo separado del entorno de rescate legítimo.
- **`THREAT_HUNTING/`**: (NUEVO) Base de conocimientos para YARA rules e Indicadores de Compromiso. Separado para evitar bloqueos por falsos positivos del AV local.

