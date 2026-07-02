[CmdletBinding()]
param(
    [string]$Destination,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path
if (-not $Destination) { $Destination = Join-Path $Root 'USB_RESCATE_VENTOY\tools\windows' }
$LogDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $Destination, $LogDir | Out-Null
$AuditPath = Join-Path $LogDir 'WINDOWS_FIELD_KIT_AUDIT.jsonl'

function Write-Audit {
    param([string]$Event, [hashtable]$Data)
    $record = [ordered]@{ timestamp = (Get-Date).ToUniversalTime().ToString('o'); event = $Event }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 6) | Add-Content -Path $AuditPath -Encoding UTF8
}

function Save-Download {
    param([string]$Id, [string]$Url, [string]$FileName)
    $path = Join-Path $Destination $FileName
    if ((Test-Path $path) -and -not $Force) {
        $hash = (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()
        "$hash *$FileName" | Set-Content -Path "$path.sha256" -Encoding ASCII
        Write-Audit -Event 'skip_existing' -Data @{ id = $Id; file = $path; sha256 = $hash }
        return $path
    }
    $tmp = "$path.partial"
    if (Test-Path $tmp) { Remove-Item -LiteralPath $tmp -Force }
    Write-Host "Downloading $Id -> $FileName"
    Invoke-WebRequest -Uri $Url -OutFile $tmp -MaximumRedirection 10 -Headers @{ 'User-Agent' = 'EmergencyToolKitUSB' }
    $hash = (Get-FileHash -Algorithm SHA256 -Path $tmp).Hash.ToLowerInvariant()
    Move-Item -Force -LiteralPath $tmp -Destination $path
    "$hash *$FileName" | Set-Content -Path "$path.sha256" -Encoding ASCII
    Write-Audit -Event 'downloaded' -Data @{ id = $Id; file = $path; sha256 = $hash; url = $Url }
    return $path
}

function Assert-MicrosoftSignature {
    param([string]$Path)
    $sig = Get-AuthenticodeSignature -FilePath $Path
    $subject = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { '' }
    if ($sig.Status -ne 'Valid' -or $subject -notmatch 'Microsoft Corporation') {
        Write-Audit -Event 'signature_failed' -Data @{ file = $Path; status = [string]$sig.Status; subject = $subject }
        throw "Invalid Microsoft signature: $Path ($($sig.Status), $subject)"
    }
    Write-Audit -Event 'signature_valid' -Data @{ file = $Path; subject = $subject }
}

$sysinternalsZip = Save-Download -Id 'sysinternals-suite' -Url 'https://download.sysinternals.com/files/SysinternalsSuite.zip' -FileName 'SysinternalsSuite.zip'
$msert = Save-Download -Id 'microsoft-safety-scanner-x64' -Url 'https://go.microsoft.com/fwlink/?LinkId=212732' -FileName 'msert-x64.exe'

Assert-MicrosoftSignature -Path $msert

$extractDir = Join-Path $Destination 'SysinternalsSuite'
if ((Test-Path $extractDir) -and $Force) { Remove-Item -LiteralPath $extractDir -Recurse -Force }
if (-not (Test-Path $extractDir)) {
    New-Item -ItemType Directory -Force -Path $extractDir | Out-Null
    Expand-Archive -Path $sysinternalsZip -DestinationPath $extractDir -Force
}

$mustVerify = @('Autoruns64.exe','procexp64.exe','Procmon64.exe','sigcheck64.exe','tcpview64.exe','Disk2vhd64.exe','sdelete64.exe')
foreach ($exe in $mustVerify) {
    $path = Join-Path $extractDir $exe
    if (Test-Path $path) { Assert-MicrosoftSignature -Path $path } else { Write-Audit -Event 'signature_target_missing' -Data @{ file = $path } }
}

Write-Host "Windows field kit ready: $Destination"
