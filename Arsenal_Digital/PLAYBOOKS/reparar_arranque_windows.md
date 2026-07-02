# Playbook: Reparacin de Arranque de Windows (Boot/EFI)

Pantallas como "Inaccessible Boot Device", "No Bootable Device" o el cĺdigo de error `0xc00000e` suelen indicar que el BCD (Boot Configuration Data) o la particin EFI estǭn corruptos.

## Pasos (Desde WinPE o USB de Instalacin de Windows)

Arranca desde Ventoy y elige una ISO de Windows 10/11. En la primera pantalla, presiona `Shift + F10` para abrir el CMD.

### 1. Intentar la reparacin automǭtica

Si tienes suerte, las herramientas bsicas lo arreglan:
```cmd
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd
```
*(Nota: Si `bootrec /fixboot` da error de "Acceso denegado", es normal en sistemas EFI modernos, salta al paso 2).*

### 2. Reparacin en Sistemas UEFI (Mtodo Bcdboot)

Si el equipo es UEFI (casi todos post-2012), la particin de arranque es oculta y formato FAT32 (EFI). Vamos a reconstruirla por completo.

**A. Asignar letra a la particin EFI:**
```cmd
diskpart
list disk
select disk 0    (el disco donde estǭ Windows)
list volume      (busca el volumen de ~100MB con formato FAT32 y estado Oculto/Sistema)
select volume 2  (cambia el '2' por el nmero de tu particin FAT32)
assign letter=V  (le asignamos la letra V)
exit
```

**B. Formatear la particin EFI corrupta (Opcional pero recomendado si estǭ muy daada):**
```cmd
format V: /FS:FAT32 /Q
```

**C. Recrear los archivos de arranque:**
Identifica en qu letra estǭ instalado Windows (A veces en WinPE, Windows estǭ en la D: o la E: en lugar de la C:). Escribe `dir C:`, `dir D:` para encontrar la carpeta `Windows`. Asumamos que estǭ en C:.

```cmd
bcdboot C:\Windows /s V: /f UEFI
```
*(Este comando le dice a Windows: Coge los archivos de arranque frescos de C:\Windows y mtelos en la particin V: configurados para UEFI).*

### 3. Salir y Reiniciar
```cmd
exit
wpeutil reboot
```
Si el BCD era el nico problema, el equipo arrancarǭ perfectamente.
