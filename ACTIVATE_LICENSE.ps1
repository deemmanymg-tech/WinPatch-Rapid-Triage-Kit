<#
ACTIVATE_LICENSE.ps1 — ReactedHQ
Creates license.json for offline activation using:
- License tier
- Receipt ID (from Gumroad/Payhip/Ko-fi)
- Purchaser email

No internet required. Does not contact any server.
#>
[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Solo Tech','Standard','MSP Team')][string]$LicenseTier = 'Solo Tech',
  [Parameter()][string]$ReceiptId = '',
  [Parameter()][string]$PurchaserEmail = '',
  [Parameter()][string]$OutputPath = (Join-Path $PSScriptRoot 'license.json')
)

function Read-Required([string]$prompt) {
  while($true) {
    $v = Read-Host $prompt
    if ($v -and $v.Trim().Length -gt 0) { return $v.Trim() }
  }
}

if (-not $ReceiptId)      { $ReceiptId = Read-Required 'Enter Receipt ID (from your marketplace email/receipt)' }
if (-not $PurchaserEmail) { $PurchaserEmail = Read-Required 'Enter Purchaser Email (the email used at checkout)' }

# Keep salt identical to WinPatchTriage.ps1
$Brand = 'ReactedHQ'
$Salt  = 'rHQ-4f686a00eea4c299ea569f8c'

$raw = "$Brand|$Salt|$LicenseTier|$ReceiptId|$($PurchaserEmail.ToLower())"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
$sha = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha.ComputeHash($bytes)
$key = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''

$lic = [pscustomobject]@{
  Brand = $Brand
  Tier = $LicenseTier
  ReceiptId = $ReceiptId
  Email = $PurchaserEmail
  LicenseKey = $key
  ActivatedAt = (Get-Date -Format o)
}

try {
  ($lic | ConvertTo-Json -Depth 6) | Out-File -FilePath $OutputPath -Encoding utf8 -Force
  Write-Host ""
  Write-Host "✓ Activated. Saved: $OutputPath" -ForegroundColor Green
  Write-Host "Tier: $LicenseTier" -ForegroundColor Cyan
  Write-Host "LicenseKey: $key" -ForegroundColor Gray
  Write-Host ""
  Write-Host "Next: run FIX_WIZARD.ps1 (recommended) or WinPatchTriage.ps1." -ForegroundColor Cyan
} catch {
  Write-Host "✗ Failed to write license file: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
