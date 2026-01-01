<#
ONE_COMMAND_COPIER.ps1 — ReactedHQ
Generates the single best command for this machine and copies it to clipboard.
Goal: reduce user error -> fewer refunds.

It does NOT modify the system. It only prints/copies commands.
#>
[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Lite','Standard','Deep')][string]$CollectorLevel = 'Standard',
  [Parameter()][string]$OutputDir = ".\WinPatchTriage_Output",
  [Parameter()][string]$Customer = "",
  [Parameter()][string]$Ticket = "",
  [Parameter()][switch]$PreferWizard,
  [Parameter()][switch]$IncludeActivationHint
)

function Is-Admin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch {
    return $false
  }
}

function Copy-ToClipboard([string]$text) {
  try {
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
      $text | Set-Clipboard
      return $true
    }
  } catch {}
  try {
    $text | clip.exe
    return $true
  } catch {}
  return $false
}

$admin = Is-Admin

# If not admin, suggest Lite (higher chance of success on locked endpoints)
if (-not $admin -and $CollectorLevel -ne 'Lite') {
  $CollectorLevel = 'Lite'
}

$base = "Set-ExecutionPolicy -Scope Process Bypass -Force; "

$customerArg = ""
if ($Customer) { $customerArg += " -Customer `"$Customer`"" }
$ticketArg = ""
if ($Ticket) { $ticketArg += " -Ticket `"$Ticket`"" }

if ($PreferWizard) {
  $cmd = $base + (".\FIX_WIZARD.ps1 -CollectorLevel {0} -OutputDir `"{1}`"{2}{3}" -f $CollectorLevel, $OutputDir, $customerArg, $ticketArg)
} else {
  $cmd = $base + (".\WinPatchTriage.ps1 -CollectorLevel {0} -OutputDir `"{1}`"{2}{3}" -f $CollectorLevel, $OutputDir, $customerArg, $ticketArg)
}

Write-Host ""
Write-Host "ReactedHQ One‑Command Copier" -ForegroundColor Cyan
Write-Host ("Admin detected: {0}" -f $admin) -ForegroundColor Gray
Write-Host ("CollectorLevel: {0}" -f $CollectorLevel) -ForegroundColor Gray
Write-Host ("OutputDir     : {0}" -f $OutputDir) -ForegroundColor Gray
Write-Host ""

Write-Host "Command:" -ForegroundColor Cyan
Write-Host $cmd -ForegroundColor Yellow
Write-Host ""

$ok = Copy-ToClipboard $cmd
if ($ok) {
  Write-Host "✓ Copied to clipboard. Paste into PowerShell and press Enter." -ForegroundColor Green
} else {
  Write-Host "⚠ Could not copy to clipboard. Manually copy the command above." -ForegroundColor Yellow
}

if (-not $admin) {
  Write-Host ""
  Write-Host "Tip: Run PowerShell as Administrator for best results (then you can use CollectorLevel Standard)." -ForegroundColor Yellow
}

if ($IncludeActivationHint) {
  Write-Host ""
  Write-Host "Optional activation (does not block usage): .\ACTIVATE_LICENSE.ps1 -LicenseTier `"Standard`"" -ForegroundColor Gray
}
