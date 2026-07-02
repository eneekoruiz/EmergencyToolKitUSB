# Playbook: Edicin del Registro de Windows Offline (En fro)

Si un driver estǭ causando un bucle de reinicios o pantallazos azules continuos y no puedes entrar ni al Modo Seguro, la ǧnica forma de solucionarlo es editar el Registro de ese Windows *desde fuera*.

## Prerrequisitos
Arranca el equipo con tu USB (Ventoy) y selecciona WinPE o una ISO de instalacin de Windows (Shift+F10 para sacar consola).

## Pasos

**1. Identificar la unidad de Windows**
Asegrate de saber dnde estǭ el disco C: real del cliente.
```cmd
dir C:
dir D:
```
(Supongamos que es D:).

**2. Abrir el Editor del Registro**
Simplemente escribe:
```cmd
regedit
```
Se abrirǭ el Editor, pero ten cuidado: **Lo que ves ahora es el registro de WinPE, NO el del equipo.**

**3. Montar la colmena (Hive) del cliente**
*   Haz clic en `HKEY_LOCAL_MACHINE`.
*   Ve al men `Archivo` -> `Cargar subárbol...` (Load Hive).
*   Navega a `D:\Windows\System32\config`.
*   Aqu verǭs archivos sin extensin. Los importantes son:
    *   `SYSTEM` (Aqu estǭn los drivers y servicios).
    *   `SOFTWARE` (Aqu estǭn los programas y configuraciones de SO).
*   Selecciona `SYSTEM` y dale a abrir.
*   Te pedirǭ un "Nombre de clave" (Key Name). Escribe algo como `RESCATE_SYSTEM`.

**4. Realizar la edicin quirrgica**
*   Ahora ve a `HKEY_LOCAL_MACHINE\RESCATE_SYSTEM`. ¡Ese es el registro de la vctima!
*   Si vas a deshabilitar un driver problemǭtico o servicio malicioso, ve a `RESCATE_SYSTEM\ControlSet001\Services\NombreDelDriver`.
*   Cambia el valor `Start` a `4` (Deshabilitado).

**5. Desmontar la colmena (CRUCIAL)**
*   Selecciona la carpeta `RESCATE_SYSTEM` que creaste.
*   Ve a `Archivo` -> `Descargar subárbol...` (Unload Hive).
*   Confirma.
*   Cierra Regedit, reinicia, y el equipo arrancarǭ sin cargar el driver malicioso.
