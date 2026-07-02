# EmergencyToolKitUSB

Kit reproducible para dos USB de emergencia:

- `USB_PRIVACIDAD_TAILS`: anonimato, arranque amnesico y persistencia cifrada con Tails.
- `USB_RESCATE_VENTOY`: multiboot de rescate, diagnostico, particionado, imagenes y recuperacion.

El repositorio no necesita guardar binarios pesados. El manifiesto en `Arsenal_Digital/00_MANIFIESTOS/tools.json` fija versiones, URLs oficiales y hashes SHA-256 cuando el proveedor los publica. Los scripts descargan, verifican y dejan auditoria local.

## Arranque rapido

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Arsenal_Digital\scripts\Build-Arsenal.ps1
.\Arsenal_Digital\scripts\Verify-Arsenal.ps1
```

Para preparar copias hacia pendrives ya montados:

```powershell
.\Arsenal_Digital\scripts\Export-ToUsb.ps1 -PrivacyDrive E: -RescueDrive F:
```

## Principios

- Tails no se arranca desde Ventoy. Va en su USB dedicado para reducir superficie de ataque.
- Ventoy se usa solo como plataforma de rescate y diagnostico.
- Ningun script destructivo se ejecuta sin parametros explicitos y confirmacion.
- Cada descarga genera logs, hash local y sidecar `.sha256`.
- Las herramientas sin verificacion criptografica fuerte quedan como opcionales o documentadas, no como carga critica.

## Seleccion base

La seleccion prioriza software vivo, mantenido y de fuente oficial:

- Tails 7.9.1 para privacidad y persistencia cifrada.
- Ventoy 1.1.16 para multiboot de rescate.
- SystemRescue 13.01 como entorno principal de reparacion Linux.
- Rescuezilla 2.6.2 como GUI compatible con imagenes Clonezilla.
- Ubuntu 26.04 LTS Desktop y Server como instaladores seguros de sistema operativo.
- GParted Live 1.8.1-3 para particiones.
- Memtest86+ 8.10 extraido como ISO arrancable para diagnostico RAM.
- ShredOS para borrado seguro controlado de discos.
- Sysinternals Suite y Microsoft Safety Scanner x64 como kit Windows firmado.
- TestDisk/PhotoRec 7.2 Win64 como recuperacion portable de particiones y archivos.
- Rufus, KeePassXC, VeraCrypt y utilidades Windows como carga auxiliar opcional resuelta desde GitHub cuando procede.

## Riesgos principales corregidos

- Ventoy es practico pero aumenta la cadena de confianza. Por eso no hospeda Tails y exige verificacion SHA.
- Antivirus offline con firmas caducadas puede dar falsa seguridad. Se documenta como apoyo, no como decision final.
- Persistencia de Tails puede vincular identidades si se mezclan misiones. El protocolo separa identidades y recomienda reinicios entre contextos.
- Herramientas forenses ejecutadas sobre discos montados en escritura pueden destruir evidencia. Los runbooks empiezan con inventario y modo solo lectura.





## Validacion operacional

```powershell
.\Arsenal_Digital\scripts\Verify-Arsenal.ps1
.\Arsenal_Digital\scripts\Validate-Arsenal.ps1
.\Arsenal_Digital\scripts\Update-Arsenal.ps1 -RefreshWindowsFieldKit
```

El arsenal no se considera listo para campo hasta completar `Arsenal_Digital/TESTED_BOOT_MATRIX.md` en hardware real.
