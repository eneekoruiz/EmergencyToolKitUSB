# Arranque critico

## Si no arranca Windows

1. No ejecutes reparaciones automaticas al primer intento.
2. Captura inventario: disco, particiones, SMART.
3. Si hay datos importantes, clona o imagen antes de reparar BCD/EFI.
4. Repara arranque solo despues de confirmar backup o bajo autorizacion.

## Si el disco hace ruidos o desaparece

1. Apaga.
2. Cambia cable, puerto y alimentacion si es externo.
3. No ejecutes `chkdsk` ni reparaciones de escritura.
4. Clona con herramientas tolerantes a errores desde Linux.

## Si hay sospecha de malware

1. Aisla red.
2. No inicies sesion con credenciales administrativas.
3. Extrae datos con modo solo lectura si es posible.
4. Considera reinstalacion limpia antes que "limpiar" un sistema muy comprometido.

