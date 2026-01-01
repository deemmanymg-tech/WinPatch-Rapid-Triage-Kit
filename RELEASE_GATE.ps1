# Release gate verification script
Set-StrictMode -Off
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Write-PassGate {
  param([string]$Message)
  Write-Host "PASS: $Message" -ForegroundColor Green
}

function Fail-Gate {
  param([string]$Message)
  Write-Host "FAIL: $Message" -ForegroundColor Red
  throw $Message
}

$kitRoot = $PSScriptRoot
$winPatchScript = Join-Path $kitRoot 'WinPatchTriage.ps1'
if (-not (Test-Path $winPatchScript)) {
  Fail-Gate 'WinPatchTriage.ps1 is missing from the kit root.'
}

$powershellExe = Join-Path $PSHOME 'powershell.exe'
if (-not (Test-Path $powershellExe)) {
  Fail-Gate "Unable to locate powershell.exe under $PSHOME."
}

$outDir = Join-Path $kitRoot 'out'
$parseLog = Join-Path $kitRoot '_parse.txt'
$runLog = Join-Path $kitRoot '_run.txt'
$customer = 'ACME'
$ticket = 'INC-12345'

Remove-Item -Path $parseLog,$runLog -Force -ErrorAction SilentlyContinue
if (Test-Path $outDir) {
  Remove-Item -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
}

$parseArgs = @(
  '-NoProfile',
  '-ExecutionPolicy',
  'Bypass',
  '-Command',
  "& { & '$winPatchScript' -? }"
)

try {
  $parseProc = Start-Process -FilePath $powershellExe -ArgumentList $parseArgs -WorkingDirectory $kitRoot -RedirectStandardOutput $parseLog -Wait -PassThru
} catch {
  Fail-Gate "Failed to launch PowerShell for parsing: $($_.Exception.Message)"
}

if ($parseProc.ExitCode -ne 0) {
  Fail-Gate "WinPatchTriage parse check failed (exit code $($parseProc.ExitCode)). See $parseLog for details."
}

if (-not (Test-Path $parseLog)) {
  Fail-Gate 'Parse log (_parse.txt) was not created after the parameter check.'
}

Write-PassGate "WinPatchTriage parameter help captured in $parseLog"

Start-Transcript -Path $runLog -Force
$runError = $null
try {
  & $winPatchScript -Customer $customer -Ticket $ticket -OutputDir $outDir -CollectorLevel 'Standard' -NoLicenseNag
} catch {
  $runError = $_
} finally {
  Stop-Transcript
}

if ($runError) {
  Fail-Gate "WinPatchTriage execution failed: $($runError.Exception.Message)"
}

Write-PassGate "WinPatchTriage execution recorded in $runLog"

$reportJson = Join-Path $outDir 'report.json'
$reportHtml = Join-Path $outDir 'report.html'
$supportZip = Join-Path $outDir 'support_bundle.zip'
$supportHash = Join-Path $outDir 'support_bundle.sha256.json'

foreach ($path in @($reportJson, $reportHtml, $supportZip, $supportHash)) {
  if (-not (Test-Path $path)) {
    Fail-Gate "Expected artifact missing: $path"
  }
}

Write-PassGate "Report JSON/HTML and support bundle artifacts exist in $outDir"

try {
  $report = Get-Content $reportJson -Raw | ConvertFrom-Json
} catch {
  Fail-Gate "report.json is not valid JSON: $($_.Exception.Message)"
}

if (($report.Customer -ne $customer) -or ($report.Ticket -ne $ticket)) {
  Fail-Gate "report.json metadata mismatch (Customer=$($report.Customer), Ticket=$($report.Ticket))."
}

Write-PassGate "report.json parsed and customer/ticket match expected values"

$htmlContent = Get-Content $reportHtml -Raw
if (-not ($htmlContent -match '<title>WinPatch Rapid Triage Report</title>')) {
  Fail-Gate 'report.html does not contain the expected title.'
}

Write-PassGate 'report.html contains the expected title header'

try {
  $hashPayload = Get-Content $supportHash -Raw | ConvertFrom-Json
} catch {
  Fail-Gate "support_bundle.sha256.json is not valid JSON: $($_.Exception.Message)"
}

if (-not $hashPayload.Hash) {
  Fail-Gate 'support_bundle.sha256.json is missing the Hash value.'
}

Write-PassGate 'support_bundle.sha256.json parsed successfully'

$actualHash = (Get-FileHash -Path $supportZip -Algorithm SHA256).Hash
if ($hashPayload.Hash.ToUpperInvariant() -ne $actualHash.ToUpperInvariant()) {
  Fail-Gate 'support_bundle.zip hash does not match support_bundle.sha256.json'
}

Write-PassGate 'support_bundle.zip hash matches support_bundle.sha256.json'

if ($hashPayload.Path) {
  try {
    $declared = (Resolve-Path -Path $hashPayload.Path).Path
    $resolved = (Resolve-Path -Path $supportZip).Path
    if ($declared -ne $resolved) {
      Fail-Gate "support_bundle.sha256.json.Path ($declared) does not match actual ZIP path ($resolved)"
    }
    Write-PassGate 'support_bundle.sha256.json.Path matches the ZIP location'
  } catch {
    Fail-Gate "Cannot resolve support_bundle.sha256.json.Path: $($_.Exception.Message)"
  }
}

try {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
} catch {
  # The assembly may already be loaded; ignore any failure if it already exists.
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($supportZip)
try {
  $entries = $zip.Entries | ForEach-Object { $_.FullName }
  foreach ($entry in @('report.json', 'report.html')) {
    if (-not ($entries -contains $entry)) {
      Fail-Gate "support_bundle.zip is missing entry '$entry'"
    }
  }
} finally {
  $zip.Dispose()
}

Write-PassGate 'support_bundle.zip contains report.json and report.html'

# Evidence: output inventory
Get-ChildItem $outDir -Recurse |
  Select-Object FullName,Length,LastWriteTime |
  Sort-Object FullName |
  Set-Content -Path (Join-Path $PSScriptRoot '_out_tree.txt') -Encoding UTF8

$logPath = Join-Path $outDir 'triage.log'
if (Test-Path $logPath) {
  # Evidence: log tail
  Get-Content $logPath -Tail 120 |
    Set-Content -Path (Join-Path $PSScriptRoot '_log_tail.txt') -Encoding UTF8
}

Write-Host ''
Write-Host 'Release gate verification complete: PASS' -ForegroundColor Green
