# Playbook: Captura de Trǭfico de Red (PCAP)

Cuando sospechas que un equipo (o un dispositivo de la red como una impresora o cmara IP) estǭ comprometido y exfiltrando datos, debes "escuchar" la red antes de desconectarlo.

## Preparativos

Necesitas arrancar tu Kali Linux Live USB o Tails, o usar un portǭtil limpio con Wireshark/tcpdump instalado. Idealmente, conecta tu equipo a un Switch que permita *Port Mirroring* o usa un Network Tap fsico.

## Usando `tcpdump` (Solo Consola)

Es la herramienta ms rpida para dejar grabando trafico y analizarlo despus.

**1. Identificar tu interfaz de red:**
```bash
ip a
# O usa ifconfig. Anota el nombre (ej: eth0, wlan0).
```

**2. Capturar todo el trafico crudo a un archivo:**
```bash
# -i eth0 (interfaz)
# -w evidencia.pcap (archivo de salida)
# -s 0 (capturar el paquete completo)
sudo tcpdump -i eth0 -s 0 -w /ruta/a/tu/usb/evidencia_ransomware.pcap
```

**3. Capturar solo trǭfico de una IP sospechosa (ej. El servidor infectado en 192.168.1.50):**
```bash
sudo tcpdump -i eth0 host 192.168.1.50 -w /ruta/evidencia.pcap
```

**4. Filtrar solo puertos sospechosos (ej. conexiones SSH o RDP no autorizadas):**
```bash
sudo tcpdump -i eth0 port 3389 or port 22 -w /ruta/rdp_ssh.pcap
```

## Anǭlisis posterior (Wireshark)

Una vez detenido el volcado (`Ctrl+C`), abre el archivo `.pcap` en Wireshark (en tu equipo seguro) para un anǭlisis grǭfico.

*   Filtro para ver peticiones DNS extraas: `dns`
*   Filtro para ver trǭfico a IPs pblicas no comunes: `ip.dst != 192.168.1.0/24 and ip.dst != 10.0.0.0/8`
*   Para buscar texto en claro en paquetes HTTP: `http contains "password"`
