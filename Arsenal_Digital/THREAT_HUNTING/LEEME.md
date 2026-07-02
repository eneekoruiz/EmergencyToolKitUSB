# Mdulo: Threat Hunting y Reglas YARA

Bienvenido a las ligas mayores. Cuando el antivirus convencional falla (y a menudo lo hace ante zero-days o ransomware dirigido), usamos herramientas de Threat Hunting basadas en reglas de firma personalizadas (YARA).

## ¿Qu es esta carpeta?

`THREAT_HUNTING` es el repositorio donde guardaremos reglas YARA, IoCs (Indicadores de Compromiso) e informes de inteligencia de amenazas. No metas binarios pesados aqu, solo las "recetas" para detectar malware.

## Flujo de Trabajo (Incident Response)

1. **Mantn tus reglas actualizadas:** Antes de ir a un cliente, descarga reglas YARA recientes de repositorios pblicos (ej. las de *Yara-Rules* en GitHub o Florian Roth / Neo23x0). Cppialas en la carpeta `rules/`.
2. **Usa un escaner portǭtil:** Las herramientas como **Loki** o **Thor Lite** (de Nextron Systems) son escneres IOC/YARA geniales que puedes llevar en este USB.
3. **Ejecuta el escaneo en el equipo vctima:**
   Si usas el escaner de lnea de comandos `yara64.exe` (descargable desde su GitHub oficial), puedes hacerlo as:
   
   ```cmd
   yara64.exe -r \THREAT_HUNTING\rules\malware_index.yar C:\Windows\System32
   ```

## Estructura Recomendada para este Directorio

Crea las siguientes carpetas internas conforme tu arsenal vaya creciendo:
- `/rules`: Archivos `.yar` y `.yara` descargados.
- `/iocs`: Archivos de texto o CSV con IPs maliciosas, hashes SHA256 de ransomware de campaas recientes.
- `/tools`: (Opcional, pero vigila tu AV). Scanners como YARA engine o Loki.

## Advertencia Crtica
Las reglas YARA a menudo contienen "strings" (cadenas de texto) exactas del malware que intentan detectar. Algunos antivirus muy sensibles podran marcar los *propios archivos de reglas YARA* como amenazas. Se recomienda tener este mtodo en una particin cifrada o hacer una exclusin en tu Windows local de mantenimiento.
