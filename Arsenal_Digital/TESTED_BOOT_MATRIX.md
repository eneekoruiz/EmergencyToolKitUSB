# Tested Boot Matrix

Esta matriz es obligatoria antes de considerar el arsenal listo para campo. Una ISO descargada y verificada no equivale a una ISO probada.

## Estado de pruebas

| Payload | Ventoy UEFI | Ventoy Secure Boot | Ventoy Legacy BIOS | USB dedicado | VM | Equipo real | Fecha | Resultado | Notas |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Tails 7.9.1 | No aplica | No aplica | No aplica | Pendiente | Pendiente | Pendiente | | Pendiente | Tails debe ir en USB dedicado, no Ventoy. |
| SystemRescue 13.01 | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | Probar red, teclado, montaje read-only. |
| GParted Live 1.8.1-3 | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | Probar deteccion de NVMe/SATA/USB. |
| Rescuezilla 2.6.2 | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | Probar arranque GUI y deteccion de discos. |
| Memtest86+ 8.10 | Pendiente | Pendiente | Pendiente | Opcional | No aplica | Pendiente | | Pendiente | Probar en hardware real, varias pasadas. |
| Ubuntu 26.04 LTS Desktop | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | Probar live session e instalador. |
| Ubuntu 26.04 LTS Server | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | Probar instalador y red. |
| ShredOS | Pendiente | Pendiente | Pendiente | Opcional | Pendiente | Pendiente | | Pendiente | No ejecutar wipe real salvo disco de prueba. |

## Criterio de aprobado

- Cada payload critico debe arrancar al menos en una VM y un equipo fisico.
- El USB Tails debe probarse como USB dedicado.
- El USB Ventoy debe probarse en UEFI y, si lo necesitas en campo, en Legacy BIOS.
- Las pruebas destructivas usan discos de laboratorio claramente etiquetados.
- Toda incidencia se registra en `case_notes` o en el campo Notas.
