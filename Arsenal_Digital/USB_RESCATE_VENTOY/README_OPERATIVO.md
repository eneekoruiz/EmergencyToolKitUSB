# USB_RESCATE_VENTOY - README OPERATIVO

## Que es

USB multiboot de rescate para reparar equipos, diagnosticar hardware, clonar discos, recuperar datos y arrancar herramientas especializadas.

## Caso de uso extremo

- Windows o Linux no arranca.
- Disco con SMART degradado.
- Particiones danadas o borradas.
- Necesidad de clonacion antes de manipular un sistema.
- Validacion de RAM o hardware inestable.

## Instrucciones de arranque critico

1. Arranca desde Ventoy.
2. Si sospechas fallo fisico de disco, usa primero SystemRescue y captura SMART.
3. Si el usuario necesita rescate rapido visual, usa Rescuezilla.
4. Para particiones, usa GParted Live y confirma que existe backup.
5. Para memoria inestable, usa Memtest86+ varias pasadas.

## Protocolo de seguridad

- No repares antes de clonar si hay datos importantes.
- Monta discos sospechosos en solo lectura cuando sea posible.
- Registra hora, disco, numero de serie y accion en `case_notes`.
- No guardes credenciales reales en el USB de rescate salvo dentro de un KDBX cifrado.
- Si Ventoy pide enrolar clave Secure Boot, hazlo solo en equipos propios o con permiso explicito.

## Layout recomendado del USB Ventoy

```text
ISO/
  01_rescue/
  02_partitioning/
  03_imaging/
  04_hardware/
tools/
  windows/
  ventoy/
case_notes/
docs/
```

