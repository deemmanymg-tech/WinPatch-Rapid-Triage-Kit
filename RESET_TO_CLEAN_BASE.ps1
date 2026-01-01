<#
RESET_TO_CLEAN_BASE.ps1 — ReactedHQ
Deletes ONLY the tool output folder you specify (default: .\WinPatchTriage_Output).
Does NOT uninstall updates or modify system configuration.
#>
[CmdletBinding()]
param(
  [Parameter()][string]$OutputDir = ".\WinPatchTriage_Output"
)

Write-Host "Resetting tool output folder to a clean base..." -ForegroundColor Cyan
Write-Host "Target: $OutputDir" -ForegroundColor Gray

if (Test-Path $OutputDir) {
  try {
    Remove-Item -Path $OutputDir -Recurse -Force -ErrorAction Stop
    Write-Host "✓ Removed: $OutputDir" -ForegroundColor Green
  } catch {
    Write-Host "✗ Could not remove output folder: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tip: close any open report.html or Explorer windows pointing at the folder, then try again." -ForegroundColor Yellow
    exit 1
  }
} else {
  Write-Host "Nothing to remove (folder not found)." -ForegroundColor Green
}

Write-Host "Done." -ForegroundColor Green
