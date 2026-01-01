<#
FIX_WIZARD.ps1 — ReactedHQ
Guided, safe "do-this-next" assistant. Does not auto-install patches.
It helps you:
1) Run triage (before)
2) If needed, open OOB update catalog links
3) Perform safe restarts / reboot suggestion
4) Run triage (after)
5) Compare results and explain what changed
#>
[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Lite','Standard','Deep')][string]$CollectorLevel = 'Standard',
  [Parameter()][string]$OutputDir = ".\WinPatchTriage_Output",
  [Parameter()][string]$Customer = "",
  [Parameter()][string]$Ticket = ""
)

function AskYesNo([string]$q){
  while($true){
    $a = Read-Host "$q (Y/N)"
    if ($a -match '^(y|yes)$') { return $true }
    if ($a -match '^(n|no)$')  { return $false }
  }
}

Write-Host ""
Write-Host "ReactedHQ WinPatch Fix Wizard" -ForegroundColor Cyan
Write-Host "CollectorLevel: $CollectorLevel"
Write-Host "OutputDir      : $OutputDir"
Write-Host ""

# Step 0: pre-open safety
Write-Host "Step 0 — Pre-check" -ForegroundColor Cyan
Write-Host "• Close any open report.html from previous runs."
Write-Host "• Run PowerShell as Administrator for best results."
Write-Host ""

# Step 1: Run BEFORE triage
Write-Host "Step 1 — Run triage (BEFORE)" -ForegroundColor Cyan
$beforeDir = Join-Path $OutputDir "before"
New-Item -ItemType Directory -Path $beforeDir -Force | Out-Null

& .\WinPatchTriage.ps1 -CollectorLevel $CollectorLevel -OutputDir $beforeDir -Customer $Customer -Ticket $Ticket
$beforeJson = Join-Path $beforeDir "report.json"

if (-not (Test-Path $beforeJson)) {
  Write-Host "Could not find BEFORE report.json. Check triage.log in $beforeDir." -ForegroundColor Red
  exit 1
}

# Load before JSON
$B = Get-Content $beforeJson -Raw | ConvertFrom-Json
Write-Host ""
Write-Host ("Detected Risk: {0} (Issues: {1})" -f $B.Summary.RiskLevel, @($B.Summary.Issues).Count) -ForegroundColor Yellow

# Step 2: Suggest next steps
Write-Host ""
Write-Host "Step 2 — Next actions (safe)" -ForegroundColor Cyan

$needOob = $false
try {
  if ($B.Oob -and $B.Oob.RecommendedKb -and -not $B.Oob.Present) { $needOob = $true }
} catch {}

if ($needOob) {
  Write-Host ("• Matching Out-of-Band update NOT detected: {0}" -f $B.Oob.RecommendedKb) -ForegroundColor Yellow
  if (AskYesNo "Open Microsoft Update Catalog search links now?") {
    & .\OPEN_OOB_LINKS.ps1
  }
  Write-Host "After installing the matching OOB update, reboot if prompted." -ForegroundColor Yellow
} else {
  Write-Host "• No missing OOB update detected by the kit." -ForegroundColor Green
}

if ($B.MSMQ -and $B.MSMQ.Present) {
  Write-Host ""
  Write-Host "MSMQ present. Safe actions you can try:" -ForegroundColor Yellow
  Write-Host "• Restart MSMQ service (if allowed) / restart dependent app services"
  Write-Host "• Reboot during a maintenance window"
  if (AskYesNo "Run safe restarts now (MSMQ + Explorer)?") {
    & .\ApplyMitigation.ps1 -RestartMSMQ -RestartExplorer
  }
}

# Step 3: Run AFTER triage
Write-Host ""
Write-Host "Step 3 — Run triage (AFTER)" -ForegroundColor Cyan
$afterDir = Join-Path $OutputDir "after"
New-Item -ItemType Directory -Path $afterDir -Force | Out-Null

& .\WinPatchTriage.ps1 -CollectorLevel $CollectorLevel -OutputDir $afterDir -Customer $Customer -Ticket $Ticket
$afterJson = Join-Path $afterDir "report.json"

if (-not (Test-Path $afterJson)) {
  Write-Host "Could not find AFTER report.json. Check triage.log in $afterDir." -ForegroundColor Red
  exit 1
}

# Step 4: Compare
Write-Host ""
Write-Host "Step 4 — Compare BEFORE vs AFTER" -ForegroundColor Cyan
& .\COMPARE_REPORTS.ps1 -Before $beforeJson -After $afterJson

Write-Host ""
Write-Host "Done. Open the HTML reports if you want:" -ForegroundColor Cyan
Write-Host "  BEFORE: $beforeDir\report.html"
Write-Host "  AFTER : $afterDir\report.html"
