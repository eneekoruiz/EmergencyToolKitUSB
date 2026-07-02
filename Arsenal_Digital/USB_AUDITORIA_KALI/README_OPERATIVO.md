# Módulo: Auditoría y Pentesting (Kali/Parrot)

> [!CAUTION]
> **Separación de Funciones:** 
> Este módulo está separado a propósito del USB de Rescate Limpio (Ventoy) y el de Privacidad (Tails).
> Mezclar herramientas de rescate legítimas con herramientas ofensivas (exploits, shellcodes) causa graves problemas con los Antivirus locales y puede contaminar una investigación forense.

## Uso Previsto
Este módulo es la estructura base para tu entorno ofensivo. Si creas un USB con Kali Linux Live (o una partición de Ventoy aislada), puedes usar esta carpeta para mantener persistencia, scripts, y notas.

## Contenido Sugerido para esta Carpeta

Si configuras persistencia en tu USB de Kali, asegúrate de guardar aquí:

1. **Wordlists:** (rockyou.txt, seclists).
2. **Scripts Ofensivos Custom:** Tus scripts de Nmap (`.nse` personalizados), bash scripts para automatización de reconocimiento.
3. **Evidencias de Auditoría:** Reportes exportados de Nessus, volcados de tráfico (PCAP) de Wireshark.

## Reglas de Enfrentamiento (Rules of Engagement - RoE)

1. **Autorización:** NUNCA conectes este módulo ni ejecutes escaneos sin autorización *explícita y por escrito* del cliente.
2. **Conciencia del Entorno:** Ejecutar herramientas agresivas puede tirar servicios frágiles (ej. PLCs industriales, impresoras, servidores legacy).
3. **Control de Evidencia:** Todo lo recolectado debe ser tratado como confidencial y debe ser destruido/cifrado después de la entrega del reporte final.
