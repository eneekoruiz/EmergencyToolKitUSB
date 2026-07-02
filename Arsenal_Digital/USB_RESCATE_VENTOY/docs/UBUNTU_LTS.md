# Ubuntu LTS e instaladores

## Que llevo

- Ubuntu 26.04 LTS Desktop AMD64: live session, instalacion de escritorio, recuperacion basica y prueba de compatibilidad hardware.
- Ubuntu 26.04 LTS Server AMD64: instalacion limpia de servidor, laboratorio, NAS ligero, hypervisor base o reparacion desde instalador.

## Por que 26.04 LTS

Es la LTS actual publicada por Canonical en `releases.ubuntu.com`. La politica del kit es preferir LTS sobre interim: mas soporte, menos sorpresas y mejor encaje en entornos reales.

## Uso recomendado

- En Ventoy: copia las ISO en `ISO/05_installers/` y arranca directamente.
- En USB dedicado: usa Rufus desde `tools/windows/` y graba la ISO de escritorio o servidor.
- Para reinstalacion de equipo de cliente: guarda antes drivers, BitLocker recovery key, licencia, perfil de usuario y backup verificable.

## Protocolo de seguridad

- Verifica SHA-256 antes de instalar.
- Si el equipo venia comprometido, no reutilices particiones del sistema salvo que se borren y se recree tabla de particiones.
- No importes claves SSH, tokens o navegadores antiguos sin revisar.
- Activa cifrado de disco cuando el caso de uso lo permita.
