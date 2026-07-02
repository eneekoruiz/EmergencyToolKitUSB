# Cheat Sheet: Comandos Linux para Rescate

Esta guía es de referencia rápida para cuando utilices Tails o un Live USB de Linux (Ubuntu/SystemRescue) para arreglar un sistema roto.

## Montaje y Gestión de Discos

**1. Listar discos y particiones:**
```bash
lsblk
fdisk -l
```

**2. Montar particiones Windows NTFS:**
```bash
mkdir -p /mnt/windows
mount -t ntfs-3g /dev/sdXn /mnt/windows
```
*Si da error porque el sistema Windows hibernó (Fast Boot), forzar:*
```bash
ntfsfix /dev/sdXn
mount -t ntfs-3g -o remove_hiberfile /dev/sdXn /mnt/windows
```

**3. Montar discos cifrados con LUKS:**
```bash
cryptsetup luksOpen /dev/sdXn crypt_disk
mount /dev/mapper/crypt_disk /mnt/rescue
```

## Entorno Chroot (Reparación de Linux)
Si un sistema Linux no arranca, monta su raíz y entra en `chroot` para repararlo (ej. arreglar GRUB o actualizar initramfs).

```bash
mount /dev/sdX_root /mnt
mount /dev/sdX_boot /mnt/boot # Si hay partición boot
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt
```
Dentro del chroot (reparar GRUB):
```bash
update-grub
grub-install /dev/sdX
```

## Clonado a Nivel de Bloque
> [!CAUTION]
> El comando `dd` destruye datos permanentemente si inviertes `if` y `of`. Comprueba dos veces.

**1. Clonar disco defectuoso a disco sano:**
```bash
dd if=/dev/sda of=/dev/sdb bs=4M status=progress
```

**2. Crear imagen comprimida de un disco:**
```bash
dd if=/dev/sda bs=4M status=progress | gzip -c > /mnt/usb/imagen_disco.img.gz
```

**3. Restaurar imagen comprimida:**
```bash
gunzip -c /mnt/usb/imagen_disco.img.gz | dd of=/dev/sda bs=4M status=progress
```

## Análisis de Red Rápido
```bash
# Ver IPs
ip a

# Escanear puertos locales rápidamente (requiere nmap)
nmap -T4 -F 192.168.1.0/24
```
