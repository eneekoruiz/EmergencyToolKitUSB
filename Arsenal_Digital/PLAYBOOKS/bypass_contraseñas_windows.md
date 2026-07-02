# Playbook: Bypass de Contraseas de Administrador Local en Windows

> [!WARNING]
> Usar solo con autorizacin expresa del propietario del equipo. NO funciona si la unidad estǭ cifrada con BitLocker (requieres la clave de recuperacin primero) ni en cuentas de dominio/Microsoft accounts online (solo cuentas LOCALES).

## Mtodo 1: Utilman / Sethc (Desde WinPE o Live USB de Linux)

Este mtodo sustituye la herramienta de accesibilidad en la pantalla de inicio de sesin por una consola de comandos con privilegios de SYSTEM.

1. **Arranca con Ventoy** -> Elige una ISO de Windows (o WinPE, Hirens, Linux).
2. **Si usas WinPE/Windows Setup**, presiona `Shift + F10` cuando aparezca la primera pantalla de instalacin para abrir CMD.
3. **Localiza la letra de la unidad del SO** (Suele ser C: o D:). Ej: `dir C:`
4. **Haz copia de seguridad de Utilman:**
   ```cmd
   copy C:\Windows\System32\utilman.exe C:\Windows\System32\utilman.exe.bak
   ```
5. **Sobrescribe Utilman con CMD:**
   ```cmd
   copy /y C:\Windows\System32\cmd.exe C:\Windows\System32\utilman.exe
   ```
6. **Reinicia el equipo normalmente** (`wpeutil reboot`).
7. **En la pantalla de login**, haz clic en el icono de *Accesibilidad* (abajo a la derecha).
8. Se abrirǭ una consola `cmd.exe` como `NT AUTHORITY\SYSTEM`.
9. **Cambia la contrasea** o activa el Administrador:
   ```cmd
   # Ver usuarios
   net user
   # Cambiar contrasea
   net user NombreUsuario NuevaContrasea123!
   # O activar el Adminstrador oculto
   net user Administrador /active:yes
   ```
10. ¡IMPORTANTE! Cuando termines, revierte el cambio arrancando de nuevo el USB:
    ```cmd
    copy /y C:\Windows\System32\utilman.exe.bak C:\Windows\System32\utilman.exe
    ```

## Mtodo 2: `chntpw` (Desde Kali o SystemRescue Linux)

Si estǭs en Linux, puedes editar directamente el archivo de Registro `SAM`.

1. **Monta la particin Windows**. (Ej: `mount /dev/sda3 /mnt/windows`)
2. **Ve al directorio de configuracin:**
   ```bash
   cd /mnt/windows/Windows/System32/config
   ```
3. **Ejecuta `chntpw`:**
   ```bash
   chntpw -i SAM
   ```
4. Sigue el men interactivo:
   - Presiona `1` para listar usuarios.
   - Escribe el RID del usuario (en formato Hex) o el nombre.
   - Presiona `1` para limpiar (blanquear) la contrasea o `2` para desbloquear/activar la cuenta.
   - Presiona `q` para salir y `y` para guardar (Write hive files? Yes).
5. Reinicia. El usuario ya no tendrǭ contrasea.
