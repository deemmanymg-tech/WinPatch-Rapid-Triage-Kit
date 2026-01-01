<#
Build.ps1 — packaging helper for WinPatch Rapid Triage Kit

Creates:
- WinPatchRapidTriageKit_v1_1.zip
- WinPatchRapidTriageKit_v1_1.sha256.txt

Optionally signs PS1 files if you have a code-signing cert.
#>

[CmdletBinding()]
param(
  [string]$OutDir = ".\dist",
  [string]$Version = "1.1.0",
  [switch]$Sign,
  [string]$CertThumbprint = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$p){ if(-not (Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Ensure-Dir $OutDir

$files = @("WinPatchTriage.ps1","ApplyMitigation.ps1","Export-SupportBundle.ps1","README.md","LICENSE.txt","CHANGELOG.md")
foreach($f in $files){ if(-not (Test-Path $f)){ throw "Missing file: $f" } }

if($Sign){
  if(-not $CertThumbprint){ throw "Provide -CertThumbprint when -Sign is used." }
  $cert = Get-Item "Cert:\CurrentUser\My\$CertThumbprint" -ErrorAction Stop
  foreach($ps1 in @("WinPatchTriage.ps1","ApplyMitigation.ps1","Export-SupportBundle.ps1")){
    Set-AuthenticodeSignature -FilePath $ps1 -Certificate $cert | Out-Null
  }
  Write-Host "Signed scripts with cert thumbprint $CertThumbprint"
}

$zipName = "WinPatchRapidTriageKit_v$Version.zip"
$zipPath = Join-Path $OutDir $zipName
if(Test-Path $zipPath){ Remove-Item $zipPath -Force }

Compress-Archive -Path $files -DestinationPath $zipPath -CompressionLevel Optimal

$hash = Get-FileHash $zipPath -Algorithm SHA256
"$($hash.Hash)  $zipName" | Out-File (Join-Path $OutDir "WinPatchRapidTriageKit_v$Version.sha256.txt") -Encoding ascii

Write-Host "Built: $zipPath"
Write-Host "SHA256: $($hash.Hash)"
