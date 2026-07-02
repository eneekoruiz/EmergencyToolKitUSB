# Protocolo Bóveda de Secretos (SECRETS)

Durante una intervención, a menudo necesitarás almacenar credenciales temporales, claves de recuperación de BitLocker, contraseñas de routers o credenciales de administrador de dominio de tus clientes.

**NUNCA ALMACENES CONTRASEÑAS EN TEXTO PLANO (TXT/MD) EN EL USB.**
Si pierdes el USB de rescate, estarías entregando las llaves del reino a un atacante.

## Solución Recomendada: KeePassXC Portable

1. Descarga [KeePassXC Portable](https://keepassxc.org/download/).
2. Coloca la carpeta de la aplicación dentro de `/tools/keepassxc/` (en el USB de rescate).
3. Crea aquí (`/SECRETS/`) un archivo `.kdbx` vacío llamado `boveda_rescate.kdbx`.
4. Protégelo con una contraseña maestra robusta y (opcionalmente) un archivo Keyfile que guardes en tu móvil o en un YubiKey.

## Alternativa: VeraCrypt Portable

Si necesitas almacenar archivos sensibles enteros (notas forenses privadas, bases de datos de clientes, configuraciones de red):

1. Descarga [VeraCrypt Portable](https://veracrypt.fr/en/Downloads.html).
2. Crea un contenedor cifrado (ej. `datos_sensibles.hc`) en esta carpeta `/SECRETS/`.
3. Monta el contenedor usando VeraCrypt cuando lo necesites, guardando todos los datos confidenciales allí dentro.

## Política de Retención
- Una vez finalizada la intervención con el cliente, **MUEVE** los secretos desde tu USB de rescate hacia el gestor de contraseñas de la empresa (o bórralos de forma segura si ya no los necesitas). 
- El USB de rescate debe quedar limpio de datos de clientes para la próxima misión.
