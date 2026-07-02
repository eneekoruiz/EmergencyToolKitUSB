# Operational Acceptance Checklist

## Antes de declarar el arsenal listo

- [ ] `scripts\Verify-Arsenal.ps1` termina con `All SHA-256 sidecars verified`.
- [ ] `scripts\Validate-Arsenal.ps1` termina con `Operational validation OK`.
- [ ] `TESTED_BOOT_MATRIX.md` tiene pruebas reales de arranque en el hardware objetivo.
- [ ] MSERT tiene menos de 10 dias o se ha ejecutado `Update-Arsenal.ps1 -RefreshWindowsFieldKit`.
- [ ] Tails esta probado en USB dedicado y no depende de Ventoy.
- [ ] Ventoy arranca SystemRescue, Rescuezilla, GParted, Ubuntu y Memtest en al menos un equipo real.
- [ ] Existe un destino externo cifrado para backups de usuario y perfiles de navegador.
- [ ] Las herramientas destructivas se han probado solo en discos de laboratorio.
- [ ] Las llaves, frases de recuperacion y KDBX no estan en el USB de rescate sin cifrado adicional.
- [ ] El repositorio GitHub contiene scripts/manifiestos, no binarios pesados.

## Cadencia de mantenimiento

| Frecuencia | Accion |
| --- | --- |
| Antes de cada salida | `Update-Arsenal.ps1 -RefreshWindowsFieldKit`; verificar MSERT y Sysinternals. |
| Mensual | `Update-Arsenal.ps1`; revisar Tails, Ventoy, SystemRescue y Ubuntu. |
| Trimestral | Repetir matriz de arranque en hardware real. |
| Tras incidente serio | Copiar logs/reportes a almacenamiento cifrado y rotar credenciales expuestas. |

## No negociables

- No usar `/MIR` para rescate de perfiles salvo espejo deliberado y documentado.
- No borrar discos sin confirmar numero de serie.
- No usar bypass de contrasenas sin autorizacion escrita o propiedad verificable.
- No prometer borrado forense de archivos sueltos en SSD.
