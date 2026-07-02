# Cheat Sheet: Forense Básico en Windows

Cuando un equipo está comprometido y necesitas recolectar evidencia (Artifacts) ANTES de formatearlo. **NO APAGUES EL EQUIPO** hasta haber completado esto.

## 1. Recolección de RAM
La memoria RAM contiene contraseñas en texto claro, claves de cifrado, conexiones de red activas y malware desencriptado.
*   **Herramienta recomendada:** FTK Imager Lite o DumpIt (de tu repositorio de descargas).
*   **Destino:** Guarda el archivo `.mem` o `.raw` en un disco duro externo GRANDE (ocupará tantos GB como RAM tenga el equipo).

## 2. Artefactos Clave para Copiar al USB
No siempre puedes hacer un volcado completo de 1TB del disco. Si tienes prisa, copia estas carpetas/archivos clave para su análisis posterior. Puedes usar un script o copiarlos manualmente:

### Registro de Windows (Registry Hives)
El registro almacena qué programas se ejecutaron y dispositivos USB se conectaron.
*Ruta:* `C:\Windows\System32\config\`
*Archivos a copiar:* `SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`
*(Nota: Están bloqueados por el SO. Si el equipo está encendido, usa una herramienta como `HoboCopy` o extrae volumen Shadow Copy. Si el equipo está apagado y arrancas desde Ventoy/Linux, puedes copiarlos directamente).*

### Logs de Eventos (Event Logs)
Quién hizo login, qué procesos fallaron, etc.
*Ruta:* `C:\Windows\System32\winevt\Logs\`
*Copiar:* Toda la carpeta (son archivos `.evtx`).

### Prefetch
Sirve para saber qué aplicaciones (malware) se ejecutaron recientemente y a qué hora.
*Ruta:* `C:\Windows\Prefetch\`
*Copiar:* Todos los archivos `.pf`.

### Amcache / Shimcache
Evidencia de ejecución de aplicaciones (incluso si ya fueron borradas).
*Ruta Amcache:* `C:\Windows\AppCompat\Programs\Amcache.hve`

### MFT (Master File Table)
El índice completo de todos los archivos creados, modificados o borrados del disco.
*   Usar herramientas como `FTK Imager` para extraer `$MFT` de la raíz del disco duro.

## 3. Análisis Rápido en Vivo (Live Response)
*   **Procesos extraños:** `tasklist /v` o ejecutar Sysinternals Process Explorer.
*   **Conexiones de red:** `netstat -ano` o Sysinternals TCPView.
*   **Autoarranque (Persistencia):** Sysinternals Autoruns (Revisar pestañas de Logon, Scheduled Tasks, y Services).
