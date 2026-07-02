# Playbook: Recuperacin de Discos Cifrados con BitLocker

En entornos modernos, si un Windows no arranca y lo conectas a otro PC (o usas WinPE), el disco te pedirǭ la clave de BitLocker para acceder a los datos.

## Prerrequisitos
1. Necesitas la **Clave de Recuperacin (48 dgitos)**.
   - El cliente la puede encontrar en su cuenta de Microsoft (aka.ms/myrecoverykey) o en su Azure AD / Intune corporativo.

## Pasos (Desde CMD como Administrador o WinPE)

**1. Verificar el estado de las unidades:**
```cmd
manage-bde -status
```

**2. Desbloquear la unidad (ej. Unidad D:):**
```cmd
manage-bde -unlock D: -RecoveryPassword AAAAAA-BBBBBB-CCCCCC-DDDDDD-EEEEEE-FFFFFF-GGGGGG-HHHHHH
```
*(Cambia la letra de la unidad y los dgitos por la clave real)*

**3. Si quieres SUSPENDER BitLocker (para reparar el arranque sin que moleste):**
```cmd
manage-bde -protectors -disable D:
```

**4. Si quieres DESCIFRAR totalmente la unidad:**
```cmd
manage-bde -off D:
```
*(Nota: El descifrado completo tomarǭ horas, verifica el estado con `manage-bde -status D:`)*

## Notas Crticas
* Si tienes la **contrasea normal** (no la clave de 48 dgitos), usa:
  `manage-bde -unlock D: -Password` (te pedirǭ escribirla).
* Si Windows entra siempre en la pantalla azul de BitLocker recovery loop, arranca en WinPE, desbloquea la unidad (paso 2), suspende BitLocker (paso 3) y reinicia. El equipo arrancarǭ normalmente.
