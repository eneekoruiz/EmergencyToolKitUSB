# Playbook: Virtualizacin de Disco Fsico (RawDisk)

Este es un truco de **Ingeniera de Nivel 3**. 
Supongamos que un servidor tiene la placa base quemada, pero el disco duro estǭ intacto. Necesitas ver qu haca ese Windows o exportar una base de datos antigua ligada al hardware, pero si pones el disco en otro PC distinto, Windows darǭ un Pantallazo Azul por choque de drivers.

¿La solucin? Conectar el disco por USB y arrancar una mǭquina virtual apuntando *directamente* al disco fsico.

## 1. Mtodo con VirtualBox

1. Abre una consola `CMD` como **Administrador** en tu equipo de trabajo.
2. Identifica el nmero de disco fsico (ej. conectas el disco del cliente por USB y Windows le asigna el Disco 2).
   ```cmd
   diskpart
   list disk
   exit
   ```
3. Navega a la carpeta de VirtualBox:
   ```cmd
   cd "C:\Program Files\Oracle\VirtualBox"
   ```
4. Crea el archivo de mapeo (puntero VMDK):
   ```cmd
   VBoxManage createmedium disk --filename C:\temp\disco_cliente.vmdk --format=VMDK --variant RawDisk --property RawDrive=\\.\PhysicalDrive2
   ```
   *(Cambia PhysicalDrive2 por el nmero de disco que sea).*
5. Abre VirtualBox (ejecutado como Administrador, o no tendrǭ permisos para leer el disco fsico).
6. Crea una mǭquina virtual nueva. En la seccin de disco duro, elige "Usar un archivo de disco duro virtual existente" y selecciona el `disco_cliente.vmdk` que acabas de crear.
7. Arranca la VM.

## 2. Ventajas Crticas
* El Windows del cliente se encenderǭ creyendo que estǭ en su placa base original (o que fue migrado a un entorno virtual P2V genrico).
* Puedes usar la funcin de "Snapshots" de VirtualBox ANTES de arrancar para no daar el disco fsico en absoluto si te equivocas.
* Te permite extraer licencias de software que estn "atadas" a la instalacin.
