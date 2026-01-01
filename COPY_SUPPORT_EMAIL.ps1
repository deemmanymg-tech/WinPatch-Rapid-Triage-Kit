<#
COPY_SUPPORT_EMAIL.ps1 — ReactedHQ
Copies a ready-to-paste support email body to clipboard (reduces support friction).
#>
[CmdletBinding()]
param(
  [Parameter()][string]$OutputDir = "",
  [Parameter()][string]$Customer = "",
  [Parameter()][string]$Ticket = ""
)

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

if (-not $OutputDir -or $OutputDir.Trim().Length -eq 0) {
  Write-Host "Enter the output folder path (the kit copies this to clipboard on run):" -ForegroundColor Cyan
  $OutputDir = Read-Host "OutputDir"
}

$bundle = Join-Path $OutputDir "support_bundle.zip"
$report = Join-Path $OutputDir "report.json"
$log   = Join-Path $OutputDir "triage.log"

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("WinPatch Help Request")
$lines.Add("")
if ($Customer) { $lines.Add("Customer: $Customer") }
if ($Ticket)   { $lines.Add("Ticket: $Ticket") }
$lines.Add("Symptom: <describe what is happening>")
$lines.Add("Expected: <what you expected>")
$lines.Add("Reboot pending?: <yes/no/unknown>")
$lines.Add("Admin run?: <yes/no>")
$lines.Add("")
$lines.Add("Attachments (best): support_bundle.zip")
$lines.Add("If you cannot attach the bundle: report.json + triage.log + screenshot of Risk Assessment")
$lines.Add("")
$lines.Add("Local paths:")
$lines.Add(" - $bundle")
$lines.Add(" - $report")
$lines.Add(" - $log")
$lines.Add("")
$lines.Add("Send to: deemmanymg@gmail.com")

$body = ($lines -join [Environment]::NewLine)
if (Copy-ToClipboardSafe -Text $body) {
  Write-Host "✓ Support email body copied to clipboard." -ForegroundColor Green
  Write-Host "Paste it into an email to deemmanymg@gmail.com and attach the files above." -ForegroundColor Cyan
} else {
  Write-Host "Could not copy to clipboard. Here is the text:" -ForegroundColor Yellow
  Write-Host $body
}
