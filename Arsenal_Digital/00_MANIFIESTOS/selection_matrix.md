# Matriz de seleccion

| Area | Elegido | Alternativas descartadas | Motivo |
| --- | --- | --- | --- |
| Privacidad | Tails | Kali, Whonix en USB general | Tails esta disenado para arranque amnesico, Tor por defecto y persistencia cifrada. |
| Multiboot | Ventoy | YUMI, Easy2Boot | Ventoy es estable y simple, pero queda limitado al USB de rescate por su cadena de confianza mas amplia. |
| Rescate general | SystemRescue | Distros genericas live | Mejor concentracion de herramientas de disco, red, LUKS, LVM y recuperacion. |
| Imagen GUI | Rescuezilla | Redo Rescue | Rescuezilla esta activo y mantiene compatibilidad con Clonezilla. |
| Particiones | GParted Live | Solo GParted dentro de otra distro | ISO pequena, enfocada y con checksums oficiales. |
| RAM | Memtest86+ | PassMark MemTest86 Free | Memtest86+ es open source; PassMark moderno es propietario. |
| Clonacion CLI | Clonezilla | Herramientas propietarias | Se documenta, pero queda desactivado en el manifiesto si no hay SHA-256 oficial automatizable. |
| USB writer | Rufus | Balena Etcher | Rufus es pequeno, open source y excelente en Windows; Etcher usa Electron y pesa mas. |
| Credenciales | KeePassXC | Gestores cloud | KDBX offline, portable y auditable. |

