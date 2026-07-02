[CmdletBinding()]
param(
    [string]$Root,
    [string]$ManifestPath,
    [switch]$IncludeOptional,
    [switch]$Force,
    [switch]$PlanOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Root) { $Root = (Resolve-Path (Join-Path $ScriptRoot '..')).Path }
if (-not $ManifestPath) { $ManifestPath = Join-Path $Root '00_MANIFIESTOS\tools.json' }
$tls = [Net.SecurityProtocolType]::Tls12
if ([enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls13') {
    $tls = $tls -bor [Net.SecurityProtocolType]::Tls13
}
[Net.ServicePointManager]::SecurityProtocol = $tls

$LogDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$AuditPath = Join-Path $LogDir 'DOWNLOAD_AUDIT.jsonl'
$TranscriptPath = Join-Path $LogDir ("build-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Start-Transcript -Path $TranscriptPath | Out-Null

function Write-Audit {
    param([string]$Event, [hashtable]$Data)
    $record = [ordered]@{
        timestamp = (Get-Date).ToUniversalTime().ToString('o')
        event = $Event
    }
    foreach ($key in $Data.Keys) { $record[$key] = $Data[$key] }
    ($record | ConvertTo-Json -Compress -Depth 8) | Add-Content -Path $AuditPath -Encoding UTF8
}

function Get-GitHubReleaseAsset {
    param([pscustomobject]$GitHub)

    $tag = [string]$GitHub.tag
    if ($tag -eq 'latest') {
        $uri = "https://api.github.com/repos/$($GitHub.owner)/$($GitHub.repo)/releases/latest"
    } else {
        $uri = "https://api.github.com/repos/$($GitHub.owner)/$($GitHub.repo)/releases/tags/$tag"
    }

    $release = Invoke-RestMethod -Uri $uri -Headers @{ 'User-Agent' = 'EmergencyToolKitUSB' }
    $asset = $release.assets | Where-Object { $_.name -like $GitHub.assetPattern } | Select-Object -First 1
    if (-not $asset) {
        throw "No GitHub asset matched pattern '$($GitHub.assetPattern)' in $($GitHub.owner)/$($GitHub.repo)."
    }

    $sha256 = $null
    if ($asset.PSObject.Properties.Name -contains 'digest' -and $asset.digest -match '^sha256:(?<hash>[a-fA-F0-9]{64})$') {
        $sha256 = $Matches.hash.ToLowerInvariant()
    }

    [pscustomobject]@{
        Url = $asset.browser_download_url
        FileName = $asset.name
        Sha256 = $sha256
        Version = $release.tag_name
    }
}

function Get-JsonProperty {
    param(
        [pscustomobject]$Object,
        [string]$Name,
        $Default = $null
    )

    if ($Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $Default
}
function Save-Asset {
    param([pscustomobject]$Asset)

    if (-not $IncludeOptional -and $Asset.enabled -eq $false) {
        Write-Audit -Event 'skip_optional' -Data @{ id = $Asset.id; reason = 'disabled in manifest' }
        return
    }

    $resolvedUrl = Get-JsonProperty -Object $Asset -Name 'url'
    $resolvedHash = Get-JsonProperty -Object $Asset -Name 'sha256'
    $resolvedFileName = Get-JsonProperty -Object $Asset -Name 'fileName'
    $resolvedVersion = Get-JsonProperty -Object $Asset -Name 'version'

    if ($Asset.PSObject.Properties.Name -contains 'github') {
        $githubAsset = Get-GitHubReleaseAsset -GitHub $Asset.github
        $resolvedUrl = $githubAsset.Url
        if ($githubAsset.Sha256) { $resolvedHash = $githubAsset.Sha256 }
        if ($Asset.fileName -like '*latest*') { $resolvedFileName = $githubAsset.FileName }
        $resolvedVersion = $githubAsset.Version
    }

    if (-not $resolvedHash) {
        throw "Asset '$($Asset.id)' has no SHA-256. Refusing download under zero-residue policy."
    }

    $destDir = Join-Path $Root $Asset.destination
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $destPath = Join-Path $destDir $resolvedFileName
    $shaPath = "$destPath.sha256"

    if ((Test-Path $destPath) -and -not $Force) {
        $existingHash = (Get-FileHash -Algorithm SHA256 -Path $destPath).Hash.ToLowerInvariant()
        if ($existingHash -eq $resolvedHash.ToLowerInvariant()) {
            "$resolvedHash *$resolvedFileName" | Set-Content -Path $shaPath -Encoding ASCII
            Write-Audit -Event 'skip_existing_verified' -Data @{ id = $Asset.id; file = $destPath; sha256 = $existingHash }
            return
        }
        Write-Audit -Event 'existing_hash_mismatch' -Data @{ id = $Asset.id; file = $destPath; actual = $existingHash; expected = $resolvedHash }
    }

    $tmpPath = "$destPath.partial"
    if (Test-Path $tmpPath) { Remove-Item -LiteralPath $tmpPath -Force }

    Write-Host "Downloading $($Asset.id) $resolvedVersion -> $resolvedFileName"
    Write-Audit -Event 'download_start' -Data @{ id = $Asset.id; url = $resolvedUrl; file = $destPath; version = $resolvedVersion }
    Invoke-WebRequest -Uri $resolvedUrl -OutFile $tmpPath -MaximumRedirection 10 -Headers @{ 'User-Agent' = 'EmergencyToolKitUSB' }

    $actualHash = (Get-FileHash -Algorithm SHA256 -Path $tmpPath).Hash.ToLowerInvariant()
    if ($actualHash -ne $resolvedHash.ToLowerInvariant()) {
        Write-Audit -Event 'hash_failed' -Data @{ id = $Asset.id; actual = $actualHash; expected = $resolvedHash }
        throw "Hash mismatch for $($Asset.id). Expected $resolvedHash but got $actualHash."
    }

    Move-Item -Force -LiteralPath $tmpPath -Destination $destPath
    "$actualHash *$resolvedFileName" | Set-Content -Path $shaPath -Encoding ASCII
    Write-Audit -Event 'download_verified' -Data @{ id = $Asset.id; file = $destPath; sha256 = $actualHash; source = $Asset.source }
}

try {
    $manifest = Get-Content -Raw -Path $ManifestPath | ConvertFrom-Json
    if ($PlanOnly) {
        $manifest.assets | Where-Object { $IncludeOptional -or $_.enabled -ne $false } | Select-Object id, enabled, profile, version, fileName, destination, source | Format-Table -AutoSize
        Write-Audit -Event 'plan_only_complete' -Data @{ root = $Root; count = @($manifest.assets).Count }
        return
    }
    foreach ($asset in $manifest.assets) {
        Save-Asset -Asset $asset
    }
    Write-Audit -Event 'build_complete' -Data @{ root = $Root }
}
finally {
    Stop-Transcript | Out-Null
}








