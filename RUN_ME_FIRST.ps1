<#
RUN_ME_FIRST.ps1 — ReactedHQ
Primary entrypoint: runs the One‑Command Copier (recommended wizard flow)
and guides the user to paste/run the copied command.

This script does NOT modify the system.
#>
[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Lite','Standard','Deep')][string]$CollectorLevel = 'Standard',
  [Parameter()][string]$OutputDir = ".\WinPatchTriage_Output",
  [Parameter()][string]$Customer = "",
  [Parameter()][string]$Ticket = ""
)




# -----------------------------
# AUTO-OUTPUT (Desktop) + Clipboard (v1.6.1)
# -----------------------------
function New-DefaultOutputDir {
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $base = Join-Path $env:USERPROFILE "Desktop\ReactedHQ_WinPatch_Output"
  $dir = Join-Path $base $ts
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  return $dir
}

function Copy-ToClipboardSafe {
  param([Parameter(Mandatory=$true)][string]$Text)
  try {
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
      Set-Clipboard -Value $Text
      return $true
    }
  } catch {}
  try {
    $Text | clip.exe
    return $true
  } catch {}
  return $false
}

# If OutputDir not explicitly provided or points to the script folder, prefer Desktop timestamp folder
try {
  $defaultProvided = $false
  if ($PSBoundParameters.ContainsKey('OutputDir')) { $defaultProvided = $true }

  if (-not $defaultProvided -or -not $OutputDir -or $OutputDir.Trim().Length -eq 0) {
    $OutputDir = New-DefaultOutputDir
  } else {
    # if user passed a relative path, resolve it under the script folder
    if (-not [System.IO.Path]::IsPathRooted($OutputDir)) {
      $OutputDir = Join-Path $PSScriptRoot $OutputDir
    }
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
  }

  Copy-ToClipboardSafe -Text $OutputDir | Out-Null
  Write-Host ""
  Write-Host "Output folder:" -ForegroundColor Cyan
  Write-Host "  $OutputDir" -ForegroundColor Green
  Write-Host "  (Copied to clipboard)" -ForegroundColor Gray
} catch {}

# -----------------------------
# SELF-ELEVATE (non-blocking)
# -----------------------------
function Test-IsAdmin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

if (-not (Test-IsAdmin)) {
  Write-Host ""
  Write-Host "Admin rights are recommended for best results." -ForegroundColor Yellow
  $ans = Read-Host "Relaunch as Administrator now? (Y/N)"
  if ($ans -match '^(y|yes)$') {
    try {
      $args = @("-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`"","-CollectorLevel","`"$CollectorLevel`"","-OutputDir","`"$OutputDir`"")
      if ($Customer) { $args += @("-Customer","`"$Customer`"") }
      if ($Ticket)   { $args += @("-Ticket","`"$Ticket`"") }
      Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs | Out-Null
      exit 0
    } catch {
      Write-Host "UAC elevation failed or was canceled. Continuing in LIMITED mode." -ForegroundColor Yellow
      # In limited mode, prefer Lite collectors to avoid failures
      $CollectorLevel = "Lite"
    }
  } else {
    Write-Host "Continuing in LIMITED mode (Lite collectors)." -ForegroundColor Yellow
    $CollectorLevel = "Lite"
  }
}

Write-Host ""
Write-Host "ReactedHQ — WinPatch Rapid Triage Kit" -ForegroundColor Cyan
Write-Host "Step 1 (recommended): generate ONE best command and copy it to clipboard." -ForegroundColor Cyan
Write-Host ""

# Ensure we are in the script folder
try { Set-Location -Path $PSScriptRoot } catch {}

# Call One-Command Copier in "PreferWizard" mode
& .\ONE_COMMAND_COPIER.ps1 -PreferWizard -CollectorLevel $CollectorLevel -OutputDir $OutputDir -Customer $Customer -Ticket $Ticket

Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "1) Paste the copied command into this PowerShell window" -ForegroundColor Yellow
Write-Host "2) Press Enter" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you need help, email deemmanymg@gmail.com (attach support_bundle.zip if you have it)." -ForegroundColor Gray


# -----------------------------
# AUTO-OPEN REPORT (v1.6.1)
# -----------------------------
function Test-InteractiveHost {
  try {
    return ($Host -and $Host.UI -and $Host.UI.RawUI) -ne $null
  } catch { return $false }
}

# If an HTML report exists, open it automatically for interactive users
try {
  $html = Join-Path $OutputDir "report.html"
  if (Test-Path $html) {
    if (Test-InteractiveHost) {
      Write-Host ""
      Write-Host "Opening report:" -ForegroundColor Cyan
      Write-Host "  $html" -ForegroundColor Green
      Start-Process $html | Out-Null
    } else {
      Write-Host "Report saved: $html" -ForegroundColor Green
    }
  }
} catch {}

