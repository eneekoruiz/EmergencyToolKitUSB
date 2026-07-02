# Recuperacion de datos

## Herramientas incluidas

- TestDisk 7.2 Win64: recuperacion de particiones, boot sectors y tablas de particiones.
- PhotoRec 7.2 Win64: carving de archivos cuando el sistema de archivos esta muy danado.
- Rescuezilla: imagen/restauracion GUI para clonado sencillo.
- SystemRescue: entorno Linux para `ddrescue`, `smartctl`, LVM, LUKS y recuperacion avanzada.

## Protocolo critico

1. Si el disco hace ruidos, desaparece, se calienta mucho o SMART esta mal: apaga y clona antes de operar.
2. No recuperes archivos hacia el mismo disco de origen.
3. No ejecutes `chkdsk` o reparaciones de escritura antes de imagen/clon si los datos importan.
4. Documenta modelo, serial, capacidad, sintomas y hash de imagenes.
5. Si hay indicios forenses o legales, no uses herramientas interactivas de escritura: preserva evidencia.

## Orden recomendado

- Diagnostico: SMART, cables, alimentacion, modo solo lectura si procede.
- Imagen: Rescuezilla o `ddrescue` desde SystemRescue.
- Recuperacion logica: TestDisk sobre imagen o clon.
- Carving: PhotoRec hacia disco externo limpio.
- Reparacion: solo cuando ya exista copia verificable.
