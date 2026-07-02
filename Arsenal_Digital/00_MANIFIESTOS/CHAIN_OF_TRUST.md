# Protocolo de cadena de confianza

## Prioridad de confianza

1. Hash oficial del proveedor o digest de release verificable.
2. Firma Authenticode valida de Microsoft u otro proveedor reconocido.
3. Descarga HTTPS desde fuente oficial con registro de hash local, solo para herramientas no criticas.
4. Herramientas manuales o controversiales: documentadas, no automatizadas.

## Reglas

- Todo payload critico debe tener `.sha256` local.
- Si el proveedor no publica hash ni firma verificable, la herramienta no entra como dependencia critica.
- Los binarios descargados no se suben a GitHub; se reproducen desde manifiesto.
- Los logs de auditoria se conservan localmente y se pueden copiar a almacenamiento cifrado.

## Excepciones aceptadas

- MSERT: se valida por firma Microsoft y por hash local generado, pero debe refrescarse porque caduca.
- Sysinternals: se valida por firma Microsoft en ejecutables clave y se conserva ZIP con hash local.
