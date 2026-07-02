# USB_PRIVACIDAD_TAILS - README OPERATIVO

## Que es

USB dedicado para Tails, un sistema live orientado a anonimato, uso de Tor y no dejar rastros en el equipo anfitrion salvo que se active persistencia.

## Caso de uso extremo

- Usar un equipo prestado, publico o sospechoso sin confiar en su sistema operativo.
- Comunicaciones sensibles bajo Tor.
- Gestion de secretos minimos con persistencia cifrada.
- Limpieza de metadatos antes de compartir documentos.

## Instrucciones de arranque critico

1. Usa solo este USB para Tails. No lo mezcles con Ventoy.
2. Arranca desde menu UEFI/BIOS.
3. Si necesitas ocultar uso de Tor al proveedor de red, configura Tor Bridges antes de conectar.
4. Desbloquea persistencia solo cuando sea imprescindible.
5. Reinicia Tails al cambiar de identidad, cliente o mision.

## Protocolo de seguridad

- Passphrase de persistencia: minima recomendada de 6 palabras aleatorias o 20+ caracteres reales.
- No guardes copias de documentos sensibles fuera de persistencia.
- No importes perfiles de navegador ni extensiones ajenas.
- No abras archivos de procedencia dudosa si no es necesario; si lo haces, exporta a PDF limpio o usa Metadata Cleaner.
- Nunca arranques Tails desde Ventoy: reduce anonimato operativo y anade otra capa de confianza.

## Herramientas clave incluidas por Tails

- Tor Browser.
- Persistent Storage cifrado.
- KeePassXC.
- OnionShare.
- Metadata Cleaner.
- Electrum.

