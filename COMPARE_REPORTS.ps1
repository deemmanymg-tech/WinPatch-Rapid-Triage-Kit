<#
COMPARE_REPORTS.ps1 — ReactedHQ
Compares two report.json files and prints what changed.
Useful for "before vs after" validation.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Before,
  [Parameter(Mandatory)][string]$After
)

function Load-Json([string]$p){
  if (-not (Test-Path $p)) { throw "File not found: $p" }
  return (Get-Content -Path $p -Raw -Encoding UTF8 | ConvertFrom-Json)
}

$B = Load-Json $Before
$A = Load-Json $After

Write-Host ""
Write-Host "WinPatch Diff Summary" -ForegroundColor Cyan
Write-Host "Before: $Before"
Write-Host "After : $After"
Write-Host ""

# Risk + issue count
$br = $B.Summary.RiskLevel
$ar = $A.Summary.RiskLevel
Write-Host ("RiskLevel: {0}  ->  {1}" -f $br, $ar) -ForegroundColor Yellow

$bi = @($B.Summary.Issues).Count
$ai = @($A.Summary.Issues).Count
Write-Host ("IssueCount: {0}  ->  {1}" -f $bi, $ai) -ForegroundColor Yellow

# OOB detection changes
$bkbs = @($B.InstalledKbs) | Sort-Object
$akbs = @($A.InstalledKbs) | Sort-Object

$added   = Compare-Object -ReferenceObject $bkbs -DifferenceObject $akbs -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
$removed = Compare-Object -ReferenceObject $bkbs -DifferenceObject $akbs -PassThru | Where-Object { $_.SideIndicator -eq "<=" }

Write-Host ""
Write-Host "KBs Added:" -ForegroundColor Cyan
if ($added) { $added | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green } } else { Write-Host "  (none)" -ForegroundColor Gray }

Write-Host "KBs Removed:" -ForegroundColor Cyan
if ($removed) { $removed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red } } else { Write-Host "  (none)" -ForegroundColor Gray }

# MSMQ health
if ($B.MSMQ -and $A.MSMQ) {
  Write-Host ""
  Write-Host "MSMQ:" -ForegroundColor Cyan
  Write-Host ("  Present: {0} -> {1}" -f $B.MSMQ.Present, $A.MSMQ.Present)
  Write-Host ("  Service: {0} -> {1}" -f $B.MSMQ.ServiceStatus, $A.MSMQ.ServiceStatus)
  Write-Host ("  Healthy: {0} -> {1}" -f $B.MSMQ.Healthy, $A.MSMQ.Healthy)
}

# Run errors
$be = @($B.RunErrors).Count
$ae = @($A.RunErrors).Count
Write-Host ""
Write-Host ("RunErrors: {0} -> {1}" -f $be, $ae) -ForegroundColor Yellow
if ($ae -gt 0) {
  Write-Host "After-run errors (top 5):" -ForegroundColor Cyan
  $A.RunErrors | Select-Object -First 5 | ForEach-Object { Write-Host ("  - {0}: {1}" -f $_.Step, $_.Message) -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Interpretation:" -ForegroundColor Cyan
if ($ai -lt $bi -and $ar -ne "Critical") {
  Write-Host "✓ You reduced detected risk/flags. Confirm application symptoms are resolved." -ForegroundColor Green
} elseif ($ar -eq $br -and $ai -eq $bi) {
  Write-Host "No meaningful change detected. Review NEXT_STEPS.md and consider installing the matching OOB update." -ForegroundColor Yellow
} else {
  Write-Host "Mixed change detected. Review the HTML report and event logs for the remaining blockers." -ForegroundColor Yellow
}
