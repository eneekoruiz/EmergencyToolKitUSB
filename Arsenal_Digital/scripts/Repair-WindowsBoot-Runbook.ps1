[CmdletBinding()]
param(
    [switch]$PrintCommandsOnly
)

$commands = @'
# RUNBOOK MANUAL - NO EJECUTAR A CIEGAS
# 1. Identificar particion EFI y Windows desde WinRE:
diskpart
list disk
list vol
exit

# 2. Asignar letra temporal a EFI, ejemplo:
diskpart
select vol <EFI_VOLUME_NUMBER>
assign letter=S
exit

# 3. Reconstruir arranque UEFI, ajustando C:\Windows si corresponde:
bcdboot C:\Windows /s S: /f UEFI

# 4. Retirar letra temporal:
diskpart
select vol S
remove letter=S
exit
'@

if ($PrintCommandsOnly) {
    $commands
} else {
    Write-Warning "Este runbook puede modificar arranque. Usa -PrintCommandsOnly, revisa discos y ejecuta manualmente en WinRE."
    $commands
}

