<#
ADD_TECH_SEATS.ps1 — ReactedHQ
Creates/updates seats.json (warn-only enforcement).
Use this when multiple technicians share a single purchase.

Recommended: use a shared mailbox (e.g., it@yourcompany.com) for activation.
Then list the technicians who may run the tool.

This tool never blocks execution. It only helps licensing clarity.
#>
[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Solo Tech','Standard','MSP Team')][string]$LicenseTier = 'Standard',
  [Parameter()][string[]]$Seats = @(),
  [Parameter()][string]$OutputPath = (Join-Path $PSScriptRoot 'seats.json')
)

function Read-SeatList {
  $list = New-Object System.Collections.Generic.List[string]
  Write-Host ""
  Write-Host "Enter technician identifiers (email preferred). Blank line to finish." -ForegroundColor Cyan
  while($true) {
    $v = Read-Host "Seat"
    if (-not $v -or $v.Trim().Length -eq 0) { break }
    $list.Add($v.Trim())
  }
  return $list.ToArray()
}

if (-not $Seats -or $Seats.Count -eq 0) {
  $Seats = Read-SeatList
}

$limit = switch ($LicenseTier) {
  'Solo Tech' { 1 }
  'Standard'  { 3 }
  'MSP Team'  { 10 }
  default     { 1 }
}

$obj = [pscustomobject]@{
  Brand = "ReactedHQ"
  Tier = $LicenseTier
  SeatLimit = $limit
  Seats = @($Seats)
  UpdatedAt = (Get-Date -Format o)
}

try {
  ($obj | ConvertTo-Json -Depth 6) | Out-File -FilePath $OutputPath -Encoding utf8 -Force
  Write-Host ""
  Write-Host "✓ Saved seats file: $OutputPath" -ForegroundColor Green
  Write-Host ("Seats listed: 0 (tier limit: 1)" -f @($Seats).Count, $limit) -ForegroundColor Gray
  if (@($Seats).Count -gt $limit) {
    Write-Host "⚠ Warning: Seats exceed tier limit. Tool will still run, but you should reduce seats or upgrade." -ForegroundColor Yellow
  }
} catch {
  Write-Host "✗ Failed to write seats file: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
