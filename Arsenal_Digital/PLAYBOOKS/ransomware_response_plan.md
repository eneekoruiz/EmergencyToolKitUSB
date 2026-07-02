# Playbook: Respuesta ante Ransomware

> [!WARNING]
> Este documento asume que has llegado a un equipo o red que acaba de ser infectada y las pantallas muestran mensajes de rescate. **LA VELOCIDAD Y LA PRECAUCIÓN SON CRÍTICAS.**

## FASE 1: Contención y Aislamiento (Minutos 0-5)

1. **NO APAGUES EL EQUIPO DE GOLPE.**
   - Apagar el equipo destruye la memoria RAM, donde podrían estar las claves de descifrado temporal o el binario del malware.
   - En algunos ransomwares, interrumpir el proceso de cifrado apantalla el disco (cifra el MBR) y hace los datos 100% irrecuperables.
2. **Desconecta Físicamente la Red.**
   - Quita el cable de red (RJ-45).
   - Apaga el Wi-Fi (si es portátil, busca el botón físico o desactívalo desde el SO).
3. **Desconecta Unidades Externas NO vitales.**
   - Quita discos duros USB, pendrives y unidades de red mapeadas INMEDIATAMENTE para que el malware no salte a ellos.

## FASE 2: Triaje y Evaluación (Minutos 5-15)

1. **Fotografía la Escena.**
   - Usa tu móvil para sacar fotos de la pantalla: notas de rescate, direcciones de email, montos de Bitcoin solicitados, extensiones de los archivos cifrados (`.lockbit`, `.crypt`, etc.).
2. **Volcado de Memoria RAM (Forense).**
   - *Si dispones de un USB limpio con herramientas (DumpIt, FTK Imager)*, inserta el USB, extrae la RAM a tu USB y extráelo de forma segura.
3. **Buscar el Proceso Culpable.**
   - Si el PC aún responde, abre el Administrador de Tareas. Busca procesos que estén consumiendo un 99% de Disco o CPU. NO lo mates todavía si no estás seguro de que haya terminado, pero toma nota del nombre del proceso.

## FASE 3: Identificación del Ransomware

1. Usa otro equipo seguro y navega a **[No More Ransom](https://www.nomoreransom.org/)**.
2. Sube un archivo cifrado y la nota de rescate (Crypto Sheriff).
3. Comprueba si existe un descifrador gratuito.

## FASE 4: Erradicación y Recuperación

1. **Si NO hay descifrador:**
   - La única solución es restaurar desde copias de seguridad OFFLINE.
   - Utiliza el script `Secure-WipeDisk.ps1` o arranca con Ventoy y formatea a bajo nivel las particiones comprometidas.
2. **Si SÍ hay descifrador:**
   - Descárgalo en tu USB.
   - Mata el proceso del malware.
   - Ejecuta la herramienta de descifrado.
3. **Restaurar el Sistema:**
   - Nunca confíes en un SO que ha sido comprometido con ransomware (puede haber puertas traseras, Cobalt Strike, etc.).
   - Salva los datos limpios y REINSTALA Windows desde cero.
