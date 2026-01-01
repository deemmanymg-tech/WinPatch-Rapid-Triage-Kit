<#
Export-SupportBundle.ps1 (v1.1)
Creates an MSP-friendly ZIP for escalation (Microsoft Business Support / vendor tickets).

Safe defaults:
- Includes triage output folder (reports + evtx)
- Includes systeminfo + basic hotfix list
Optional (off by default): installed programs, services, network config, WindowsUpdate.log
#>

[CmdletBinding()]
param(
  [Parameter()][string]$TriageOutputPath = ".\WinPatchTriage_Output",
  [Parameter()][string]$OutDir = ".",
  [Parameter()][switch]$IncludeInstalledPrograms,
  [Parameter()][switch]$IncludeServices,
  [Parameter()][switch]$IncludeNetwork,
  [Parameter()][switch]$IncludeWindowsUpdateLog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$p){ if(-not (Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bundleName = "SupportBundle_$env:COMPUTERNAME`_$timestamp"
$tmp = Join-Path $env:TEMP $bundleName
Ensure-Dir $tmp
Ensure-Dir $OutDir

# Copy triage output (if exists)
if (Test-Path $TriageOutputPath) {
  Copy-Item -Path (Join-Path $TriageOutputPath "*") -Destination $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# Basic system info
try { & systeminfo.exe /FO LIST | Out-File (Join-Path $tmp "systeminfo.txt") -Encoding utf8 } catch {}
try { Get-HotFix | Select-Object HotFixID,InstalledOn,Description | Sort-Object InstalledOn -Descending | Out-File (Join-Path $tmp "hotfix_list.txt") -Encoding utf8 } catch {}

if ($IncludeInstalledPrograms) {
  try {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
      Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
      Sort-Object DisplayName |
      Export-Csv (Join-Path $tmp "installed_programs.csv") -NoTypeInformation -Encoding UTF8
  } catch {}
}

if ($IncludeServices) {
  try {
    Get-Service | Select-Object Name, DisplayName, Status, StartType |
      Sort-Object Name |
      Export-Csv (Join-Path $tmp "services.csv") -NoTypeInformation -Encoding UTF8
  } catch {}
}

if ($IncludeNetwork) {
  try { & ipconfig /all | Out-File (Join-Path $tmp "ipconfig_all.txt") -Encoding utf8 } catch {}
  try { & route print | Out-File (Join-Path $tmp "route_print.txt") -Encoding utf8 } catch {}
}

if ($IncludeWindowsUpdateLog) {
  try {
    # This can be slow; only do when requested.
    $wuLog = Join-Path $tmp "WindowsUpdate.log"
    Get-WindowsUpdateLog -LogPath $wuLog -ErrorAction SilentlyContinue | Out-Null
  } catch {}
}

$zipPath = Join-Path $OutDir "$bundleName.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $tmp "*") -DestinationPath $zipPath -CompressionLevel Optimal

# Hash
$hash = Get-FileHash $zipPath -Algorithm SHA256
"$($hash.Hash)  $([IO.Path]::GetFileName($zipPath))" | Out-File (Join-Path $OutDir "$bundleName.sha256.txt") -Encoding ascii

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "✅ Support bundle created:" -ForegroundColor Green
Write-Host "  $zipPath"
Write-Host ""
