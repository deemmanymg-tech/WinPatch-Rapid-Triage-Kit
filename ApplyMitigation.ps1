<#
WinPatch Rapid Triage Kit (v1.1) - Optional guided actions
Safe-by-default: no registry hacks, no forced uninstall, no silent patch downloads.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter()][switch]$RestartMSMQ,
  [Parameter()][switch]$RestartExplorer,
  [Parameter()][switch]$OpenWindowsUpdate,
  [Parameter()][switch]$OpenInstalledUpdates
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-IsAdmin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

if (-not (Test-IsAdmin)) {
  Write-Warning "Run as Administrator for service restarts and some actions."
}

if ($OpenWindowsUpdate) { Start-Process "ms-settings:windowsupdate" }
if ($OpenInstalledUpdates) { Start-Process "control.exe" "appwiz.cpl" }

if ($RestartExplorer) {
  if ($PSCmdlet.ShouldProcess("explorer.exe", "Restart")) {
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
    Write-Host "Explorer restarted."
  }
}

if ($RestartMSMQ) {
  if ($PSCmdlet.ShouldProcess("MSMQ service", "Restart")) {
    $svc = Get-Service -Name MSMQ -ErrorAction SilentlyContinue
    if ($null -eq $svc) { throw "MSMQ service not found." }
    if ($svc.Status -eq "Running") { Stop-Service MSMQ -Force -ErrorAction SilentlyContinue }
    Start-Service MSMQ
    Write-Host "MSMQ restarted."
  }
}

Write-Host "Done."
