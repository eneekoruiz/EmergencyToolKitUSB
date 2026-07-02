# Playbook: Recuperacin de Datos Crticos (Particin RAW)

Cuando conectas el disco duro al USB y en lugar de tus archivos ves que la particin es "RAW" o te pide formatear. **NO FORMATEES.**

## Herramientas Necesarias
1. **TestDisk**: Para recuperar la tabla de particiones o el boot sector (File System daado).
2. **PhotoRec**: Para escanear el disco byte a byte ignorando el sistema de archivos (Data Carving). Extrae fotos, pdfs, docs.
*(Ambas herramientas son gratuitas, open source y estǭn en Tails y SystemRescue).*

## FASE 1: Reparar la Tabla (TestDisk)

Si de repente todo el disco es RAW, probablemente solo se corrompi la tabla de particiones o el MFT.

1. Ejecuta `testdisk` desde consola (como root en Linux o Admin en Windows).
2. Selecciona **[ Create ]** para el log.
3. Elige el disco fsico (Ej. `/dev/sda` o `Disk /dev/sda`).
4. Selecciona el tipo de particin (Casi siempre es **[Intel]** para MBR o **[EFI GPT]** para modernos).
5. Selecciona **[ Analyze ]** -> **[ Quick Search ]**.
6. Si ves las particiones perdidas marcadas en verde, presiona **Enter** y luego selecciona **[ Write ]**.
7. Reinicia.

## FASE 2: Extraccin de Supervivencia (PhotoRec)

Si TestDisk no funciona, asume que el ndice de archivos estǭ destruido, pero los archivos siguen ah.

1. Conecta un **segundo disco duro USB** (vaco y con mucha capacidad).
2. Ejecuta `photorec` desde consola.
3. Elige el disco daado.
4. Selecciona el tipo de particin (suele ser **[Unknown]** o toda la unidad).
5. Selecciona sistema de archivos (ej. **[Other]** para FAT/NTFS).
6. Te pedirǭ **dnde guardar** los archivos recuperados. ¡MUY IMPORTANTE: Elige la ruta de tu disco duro USB limpio!
7. Deja correr el proceso. Tomarǭ HORAS.
8. PhotoRec escupirǭ miles de archivos con nombres como `f12345.jpg`. Usa herramientas posteriores para ordenarlos.
