# Cheat Sheet: Diagnóstico de Redes

Guía de supervivencia cuando un cliente dice "no hay internet" o "la red va lenta", y tienes que aislar el problema en menos de 5 minutos.

## 1. El Ping de los 4 Pasos (Aislamiento Rápido)
Ejecuta estos 4 pings en orden. Si uno falla, ahí está el problema.

1. `ping 127.0.0.1` -> ¿Falla? Tarjeta de red rota o drivers corruptos.
2. `ping 192.168.x.x` (IP Local de tu máquina) -> ¿Falla? Stack TCP/IP dañado en el SO.
3. `ping 192.168.x.1` (IP del Router/Gateway) -> ¿Falla? Cable suelto, switch caído o router muerto. *(Obtén la IP con `ipconfig` o `ip a`)*
4. `ping 8.8.8.8` (DNS Google) -> ¿Falla? El ISP (proveedor de internet) tiene problemas o el router no tiene salida WAN.
5. `ping google.com` -> ¿Falla pero el anterior funcionó? El servidor DNS está caído. Cambia los DNS en el adaptador a 8.8.8.8 o 1.1.1.1.

## 2. Comandos en Windows (PowerShell/CMD)

**Ver IPs completas y servidores DNS:**
```cmd
ipconfig /all
```

**Refrescar IPs y limpiar DNS (El "reiniciar" de las redes):**
```cmd
ipconfig /release
ipconfig /renew
ipconfig /flushdns
```

**Ver quién está consumiendo la red (Puertos abiertos y conexiones activas):**
```cmd
netstat -ano
```
*(Luego busca el PID en el Administrador de Tareas para ver qué programa es).*

**Trazar la ruta (ver dónde se corta la conexión):**
```cmd
tracert 8.8.8.8
```

## 3. Resolución de Problemas Frecuentes

*   **IP 169.254.x.x (APIPA):** El PC no se está comunicando con el servidor DHCP (router). Comprueba el cable físico o reinicia el router.
*   **Ataque ARP Spoofing / IPs duplicadas:** Si la red se cae intermitentemente, alguien puede tener tu misma IP. Ejecuta `arp -a` para ver la tabla MAC y busca duplicados.
*   **Problemas de proxy ocultos (Malware):** A veces los navegadores no abren porque hay un proxy inyectado. Ve a Configuración de Windows -> Proxy y desactívalo.
