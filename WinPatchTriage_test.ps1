<# 
WinPatch Rapid Triage Kit (v1.1)


# -------------------------
# License (offline activation) (v1.6.1)
# -------------------------
$script:LicenseSalt = "rHQ-4f686a00eea4c299ea569f8c"
$script:LicensePath = Join-Path $PSScriptRoot "license.json"

function Get-LicenseKeyExpected {
  param(
    [Parameter(Mandatory)][string]$Tier,
    [Parameter(Mandatory)][string]$ReceiptId,
    [Parameter(Mandatory)][string]$Email
  )
  $raw = ("ReactedHQ|rHQ-4f686a00eea4c299ea569f8c|" + $Tier.Trim() + "|" + $ReceiptId.Trim() + "|" + $Email.Trim().ToLowerInvariant())
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $hash = $sha.ComputeHash($bytes)
  ($hash | ForEach-Object { $_.ToString("x2") }) -join ""
}

function Load-License {
  if (Test-Path $script:LicensePath) {
    try {
      return (Get-Content -Path $script:LicensePath -Raw -Encoding UTF8 | ConvertFrom-Json)
    } catch {
      return $null
    }
  }
  return $null
}

function Save-License {
  param([Parameter(Mandatory)]$Lic)
  try {
    ($Lic | ConvertTo-Json -Depth 6) | Out-File -FilePath $script:LicensePath -Encoding utf8 -Force
    return $true
  } catch {
    return $false
  }
}

function Validate-License {
  param($Lic)
  try {
    if (-not $Lic) { return $false }
    if (-not $Lic.Tier -or -not $Lic.ReceiptId -or -not $Lic.Email -or -not $Lic.LicenseKey) { return $false }
    $exp = Get-LicenseKeyExpected -Tier $Lic.Tier -ReceiptId $Lic.ReceiptId -Email $Lic.Email
    return ($exp -eq [string]$Lic.LicenseKey)
  } catch {
    return $false
  }
}

function Resolve-LicenseStatus {
  # Priority: params -> license.json -> unactivated (but do not block execution)
  $status = [ordered]@{
    Activated = $false
    Tier = $LicenseTier
    ReceiptId = $ReceiptId
    Email = $PurchaserEmail
    LicenseKey = $LicenseKey
    Notes = @()
  }

  $lic = $null

  if ($LicenseKey -and $ReceiptId -and $PurchaserEmail) {
    $lic = [pscustomobject]@{ Tier=$LicenseTier; ReceiptId=$ReceiptId; Email=$PurchaserEmail; LicenseKey=$LicenseKey; ActivatedAt=(Get-Date -Format o) }
    if (Validate-License $lic) {
      $status.Activated = $true
      $status.Notes += "Activated via command-line parameters."
      # Persist for next runs
      $null = Save-License $lic
      return $status
    } else {
      $status.Notes += "Provided LicenseKey did not validate. Continuing in unactivated mode."
    }
  }

  $fromFile = Load-License
  if ($fromFile -and (Validate-License $fromFile)) {
    $status.Activated = $true
    $status.Tier = $fromFile.Tier
    $status.ReceiptId = $fromFile.ReceiptId
    $status.Email = $fromFile.Email
    $status.LicenseKey = $fromFile.LicenseKey
    $status.Notes += "Activated via license.json"
    return $status
  }

  $status.Notes += "Not activated. Run ACTIVATE_LICENSE.ps1 to generate license.json (requires Receipt ID + purchaser email)."
  return $status
}

# -------------------------
# Seats (warn-only, non-blocking) (v1.6.1)
# -------------------------
$script:SeatsPath = Join-Path $PSScriptRoot "seats.json"

function Get-SeatLimitForTier {
  param([string]$Tier)
  switch ($Tier) {
    'Solo Tech' { return 1 }
    'Standard'  { return 3 }
    'MSP Team'  { return 10 }
    default     { return 1 }
  }
}

function Load-Seats {
  if (Test-Path $script:SeatsPath) {
    try { return (Get-Content -Path $script:SeatsPath -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { return $null }
  }
  return $null
}

function Resolve-SeatsStatus {
  param($LicStatus)
  $tier = if ($LicStatus -and $LicStatus.Tier) { [string]$LicStatus.Tier } else { 'Solo Tech' }
  $limit = Get-SeatLimitForTier -Tier $tier

  $st = [ordered]@{
    Tier = $tier
    SeatLimit = $limit
    SeatsFilePresent = $false
    SeatCount = 0
    Seats = @()
    Warnings = @()
  }

  $seats = Load-Seats
  if ($seats -and $seats.Seats) {
    $st.SeatsFilePresent = $true
    $st.Seats = @($seats.Seats | ForEach-Object { [string]$_ })
    $st.SeatCount = $st.Seats.Count

    if ($st.SeatCount -gt $limit) {
      $st.Warnings += ("seats.json lists {0} seats but your tier allows {1}. Please reduce seats or upgrade. (Tool continues running.)" -f $st.SeatCount, $limit)
    }
  }

  # Attempt to associate current user with a seat (warn-only)
  try {
    $user = [string]$env:USERNAME
    if ($st.SeatsFilePresent -and $st.SeatCount -gt 0) {
      $match = $false
      foreach ($s in $st.Seats) {
        if ($s -and ($s.ToLower().Contains($user.ToLower()))) { $match = $true; break }
      }
      if (-not $match) {
        $st.Warnings += ("Current user '{0}' does not match any entry in seats.json. This is a non-blocking warning." -f $user)
      }
    }
  } catch {}

  return $st
}



- Collects Windows patch / KB info
- Detects MSMQ + known issue KBs (Dec 2025)
- Detects StartIsBack presence and warns about black-desktop reports with KB5071546
- Exports event logs and produces report.html / report.json + support_bundle.zip

Designed for Windows PowerShell 5.1+ (works in PS7 too, but some optional collectors are 5.1-first).
#>

[CmdletBinding()]
param(
  [Parameter()][ValidateSet('Solo Tech','Standard','MSP Team')][string]$LicenseTier = 'Solo Tech',
  [Parameter()][string]$ReceiptId = '',
  [Parameter()][string]$PurchaserEmail = '',
  [Parameter()][string]$LicenseKey = '',
  [Parameter()][switch]$NoLicenseNag,
  [Parameter()][ValidateSet('Lite','Standard','Deep')][string]$CollectorLevel = 'Standard',
  [Parameter()][string]$OutputDir = ".\WinPatchTriage_Output",
  [Parameter()][string]$Customer = "",
  [Parameter()][string]$Ticket = "",
  [Parameter()][switch]$IncludeMsinfo,
  [Parameter()][switch]$IncludeMinidumps,
  [Parameter()][switch]$Redact,
  [Parameter()][switch]$NoZip
)

# --- Runtime Defaults (v1.3) ---
# Keep the tool resilient across locked-down endpoints:
# - Continue on errors; record them in triage.log + report.json (RunErrors)
# - Avoid StrictMode surprises
Set-StrictMode -Off
$ErrorActionPreference = "Continue"

# Ensure output dir exists early
try {
  if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
} catch {}

$script:RunErrors = @()
$script:LogPath   = Join-Path $OutputDir "triage.log"

function Write-Write-Log {
  param(
    [Parameter(Mandatory)][string]$Message,
    [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO'
  )
  $line = "{0} [{1}] {2}" -f (Get-Date -Format o), $Level, $Message
  try { Add-Content -Path $script:LogPath -Value $line -Encoding UTF8 } catch {}
  try {
    switch ($Level) {
      'ERROR' { Write-Host $line -ForegroundColor Red }
      'WARN'  { Write-Host $line -ForegroundColor Yellow }
      default { Write-Host $line }
    }
  } catch { Write-Host $line }
}

function Add-RunError {
  param(
    [Parameter(Mandatory)][string]$Step,
    [Parameter(Mandatory)][System.Exception]$Exception
  )
  $script:RunErrors += [pscustomobject]@{
    Step    = $Step
    Message = $Exception.Message
    Type    = $Exception.GetType().FullName
  }
  Write-Write-Log ("{0}: {1}" -f $Step, $Exception.Message) 'ERROR'
}


# -------------------------
# Helpers
# -------------------------
function Test-IsAdmin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

function Get-Preflight {
  $ep = $null
  try { $ep = Get-ExecutionPolicy -Scope Process } catch {}
  $isAdmin = $false
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    $isAdmin = $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch {}

  $diskOk = $true
  try {
    $outPath = Resolve-Path $OutputDir -ErrorAction SilentlyContinue
    if ($outPath) {
      $driveLetter = $outPath.Path.Substring(0,1)
      $drive = Get-PSDrive -Name $driveLetter -ErrorAction SilentlyContinue
      if ($drive -and $drive.Free -lt 200MB) { $diskOk = $false }
    }
  } catch {}

  $notes = @()
  if (-not $diskOk) { $notes += "Low disk space on output drive (<200MB) may cause bundle failures." }
  if (-not $isAdmin) { $notes += "Not running as Administrator - event log export may be incomplete." }

  return @{
    IsAdmin = $isAdmin
    PSVersion = $PSVersionTable.PSVersion.ToString()
    ExecutionPolicyProcess = [string]$ep
    CollectorLevel = $CollectorLevel
    DiskFreeOk = $diskOk
    Notes = $notes
  }
}

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}

function Get-OsInfo {
  return @{ ComputerName=AI; UserName=AIAli }
}
function Get-InstalledHotfixIds {
  $ids = @()
  try {
    $qfe = Get-CimInstance -ClassName Win32_QuickFixEngineering
    foreach ($x in $qfe) { if ($x.HotFixID) { $ids += $x.HotFixID.ToUpperInvariant() } }
  } catch {
    try {
      $hf = Get-HotFix
      foreach ($x in $hf) { if ($x.HotFixID) { $ids += $x.HotFixID.ToUpperInvariant() } }
    } catch {}
  }
  return ($ids | Sort-Object -Unique)
}

function Detect-StartIsBack {
  $paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
  )
  foreach ($p in $paths) {
    try {
      $items = Get-ItemProperty $p -ErrorAction SilentlyContinue
      foreach ($i in $items) {
        if ($i.DisplayName -match "StartIsBack") {
          return @{
            Present = $true
            DisplayName = $i.DisplayName
            DisplayVersion = $i.DisplayVersion
            Publisher = $i.Publisher
            InstallLocation = $i.InstallLocation
          }
        }
      }
    } catch {}
  }
  $hint = @("C:\Program Files\StartIsBack","C:\Program Files (x86)\StartIsBack") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($hint) { return @{ Present=$true; DisplayName="StartIsBack (folder detected)"; DisplayVersion=""; Publisher=""; InstallLocation=$hint } }
  return @{ Present=$false }
}

function Detect-MSMQ {
  $svc = Get-Service -Name "MSMQ" -ErrorAction SilentlyContinue
  $present = $false
  if ($null -ne $svc) { $present = $true }

  $featureState = $null

  # Client: Optional feature
  try {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName "MSMQ-Server" -ErrorAction SilentlyContinue
    if ($feature) { $featureState = $feature.State }
  } catch {}

  # Server: ServerManager feature
  if (-not $featureState) {
    try {
      if (Get-Module -ListAvailable -Name ServerManager) {
        Import-Module ServerManager -ErrorAction SilentlyContinue | Out-Null
        $f = Get-WindowsFeature -Name MSMQ-Server -ErrorAction SilentlyContinue
        if ($f) { $featureState = if ($f.Installed) { "Enabled" } else { "Disabled" } }
      }
    } catch {}
  }

  return @{
    Present = ($present -or ($featureState -eq "Enabled"))
    Service = if ($svc) { @{ Status="$($svc.Status)"; StartType="$($svc.StartType)"; Name="$($svc.Name)" } } else { $null }
    FeatureState = $featureState
    StoragePath = "C:\Windows\System32\MSMQ"
    StorageExists = (Test-Path "C:\Windows\System32\MSMQ")
  }
}

function Export-EventLogs([string]$Dir, [bool]$IncludeMSMQ) {
  $logs = @(
    "System",
    "Application",
    "Setup",
    "Microsoft-Windows-WindowsUpdateClient/Operational"
  )

  if ($IncludeMSMQ) {
    $maybe = "Microsoft-Windows-MSMQ/Operational"
    $logList = & wevtutil el 2>$null
    if ($logList -and ($logList -contains $maybe)) { $logs += $maybe }
  }

  $exported = @()
  foreach ($l in $logs) {
    $safe = ($l -replace "[\\\/:]", "_")
    $dst = Join-Path $Dir "$safe.evtx"
    try { & wevtutil epl $l $dst /ow:true; $exported += @{ Log=$l; Path=$dst; Ok=$true } }
    catch { $exported += @{ Log=$l; Path=$dst; Ok=$false; Error=$_.Exception.Message } }
  }
  return $exported
}

function Write-Json([object]$Obj, [string]$Path) {
  $json = $Obj | ConvertTo-Json -Depth 8
  [IO.File]::WriteAllText($Path, $json, (New-Object System.Text.UTF8Encoding($false)))
}

function Html-Escape([string]$s) {
  if ($null -eq $s) { return "" }
  return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;' -replace "'","&#39;")
}

function Write-HtmlReport([hashtable]$Report, [string]$Path) {
  $riskRows = ""
  foreach ($r in $Report.Risks) {
    $riskRows += "<tr><td>$(Html-Escape $r.Id)</td><td>$(Html-Escape $r.Title)</td><td>$(Html-Escape $r.Severity)</td><td>$(Html-Escape $r.Detected)</td><td>$(Html-Escape $r.Recommendation)</td></tr>`n"
  }

  $kv = $Report.OS.GetEnumerator() | Sort-Object Name
  $osRows = ($kv | ForEach-Object { "<tr><td>$(Html-Escape $_.Name)</td><td>$(Html-Escape ([string]$_.Value))</td></tr>" }) -join "`n"

  $kbList = ($Report.InstalledKBs | ForEach-Object { "<code>$(Html-Escape $_)</code>" }) -join " "

  $msmq = $Report.MSMQ
  $sib  = $Report.StartIsBack

  $html = @"
<!doctype html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>WinPatch Rapid Triage Report</title>
<style>
  body{font-family:Segoe UI,Arial,sans-serif; margin:24px; color:#111;}
  .meta{display:flex; gap:16px; flex-wrap:wrap; margin-bottom:16px;}
  .pill{border:1px solid #ddd; padding:8px 10px; border-radius:999px; background:#fafafa;}
  h1{margin:0 0 8px 0;}
  h2{margin-top:22px;}
  table{border-collapse:collapse; width:100%; margin-top:10px;}
  th,td{border:1px solid #e5e5e5; padding:8px; vertical-align:top; font-size:13px;}
  th{background:#f5f5f5; text-align:left;}
  .warn{background:#fff7ed; border:1px solid #fed7aa; padding:10px; border-radius:10px;}
  .ok{background:#f0fdf4; border:1px solid #bbf7d0; padding:10px; border-radius:10px;}
  .small{font-size:12px; color:#444;}
  code{background:#f3f4f6; padding:2px 5px; border-radius:6px;}
</style>
</head>
<body>
  <h1>WinPatch Rapid Triage Report</h1>
  <div class="meta">
    <div class="pill"><strong>Computer</strong>: $(Html-Escape $Report.OS.ComputerName)</div>
    <div class="pill"><strong>Customer</strong>: $(Html-Escape $Report.Customer)</div>
    <div class="pill"><strong>Ticket</strong>: $(Html-Escape $Report.Ticket)</div>
    <div class="pill"><strong>Generated</strong>: $(Html-Escape $Report.OS.TimeLocal)</div>
  </div>

  <div class="small">
    Diagnostics-first. This report collects data and does not modify system settings.
  </div>

  <h2>Top Risks Detected</h2>
  <table>
    <thead><tr><th>ID</th><th>Risk</th><th>Severity</th><th>Detected</th><th>Recommendation</th></tr></thead>
    <tbody>
      $riskRows
    </tbody>
  </table>

  <h2>OS & Environment</h2>
  <table>
    <thead><tr><th>Key</th><th>Value</th></tr></thead>
    <tbody>
      $osRows
    </tbody>
  </table>

  <h2>Patch / KB Snapshot</h2>
  <div class="small">Installed hotfix IDs observed:</div>
  <div style="margin-top:8px; line-height:1.8;">$kbList</div>

  <h2>MSMQ</h2>
  <div class="$(if($msmq.Present){"warn"} else {"ok"})">
    <div><strong>Present</strong>: $($msmq.Present)</div>
    <div><strong>FeatureState</strong>: $(Html-Escape ([string]$msmq.FeatureState))</div>
    <div><strong>Service</strong>: $(Html-Escape (if($msmq.Service){ "$($msmq.Service.Status) / $($msmq.Service.StartType)" } else { "Not found" }))</div>
    <div><strong>StorageExists</strong>: $($msmq.StorageExists)</div>
  </div>

  <h2>StartIsBack</h2>
  <div class="$(if($sib.Present){"warn"} else {"ok"})">
    <div><strong>Present</strong>: $($sib.Present)</div>
    <div><strong>Name</strong>: $(Html-Escape ([string]$sib.DisplayName))</div>
    <div><strong>Version</strong>: $(Html-Escape ([string]$sib.DisplayVersion))</div>
    <div><strong>InstallLocation</strong>: $(Html-Escape ([string]$sib.InstallLocation))</div>
  </div>

  <h2>Collected Artifacts</h2>
  <ul>
    <li>report.json</li>
    <li>Event logs (*.evtx)</li>
    <li>systeminfo.txt</li>
    <li>hotfixes.txt</li>
    <li>services_msmq.txt</li>
    <li>support_bundle.zip (if enabled)</li>
  </ul>

</body>
</html>
"@
  [IO.File]::WriteAllText($Path, $html, (New-Object System.Text.UTF8Encoding($false)))
}

# -------------------------
# Main
# -------------------------
$root = (Resolve-Path $OutputDir).Path 2>$null
if (-not $root) { $root = (Join-Path (Get-Location) $OutputDir) }

Ensure-Dir $root

$artifactsDir = Join-Path $root "artifacts"
Ensure-Dir $artifactsDir

$osInfo = Get-OsInfo
$preflight = Get-Preflight
Write-Log ("Preflight: Admin={0} PS={1} Level={2}" -f $preflight.IsAdmin, $preflight.PSVersion, $CollectorLevel)
if (-not $preflight.DiskFreeOk) { Write-Log 'Warning: Low disk space may affect bundle creation.' 'WARN' }
$kbs    = Get-InstalledHotfixIds
$msmq   = Detect-MSMQ
$sib    = Detect-StartIsBack

# Known issues / KB matrix (Dec 2025)
$Known = @{
  KB5071546 = "Dec 9, 2025 CU for Windows 10 ESU (19044/19045). Reported MSMQ regressions in managed environments; StartIsBack black/blank desktop reports."
  KB5071544 = "Dec 9, 2025 CU for Windows Server 2019 / Win10 Ent LTSC 2019. Reported MSMQ regressions."
  KB5071543 = "Dec 9, 2025 CU for Windows Server 2016 / Win10 Ent LTSB 2016. Reported MSMQ regressions."
  KB5074976 = "Dec 18, 2025 OOB fix for MSMQ regressions on Windows 10 ESU (19044/19045)."
  KB5074975 = "Dec 18, 2025 OOB fix for MSMQ regressions on Windows Server 2019 / Win10 Ent LTSC 2019."
  KB5074974 = "Dec 18, 2025 OOB fix for MSMQ regressions on Windows Server 2016 / Win10 Ent LTSB 2016."
  KB5071959 = "Nov 11, 2025 OOB update to fix Windows 10 Consumer ESU enrollment wizard failures."
}

function HasKB([string]$kb) { return ($kbs -contains $kb.ToUpperInvariant()) }

$risks = New-Object System.Collections.Generic.List[object]

# MSMQ risk detection
$msmqCU = (HasKB "KB5071546") -or (HasKB "KB5071544") -or (HasKB "KB5071543")
$msmqOOB = (HasKB "KB5074976") -or (HasKB "KB5074975") -or (HasKB "KB5074974")

if ($msmq.Present -and $msmqCU -and -not $msmqOOB) {
  $risks.Add([pscustomobject]@{
    Id="MSMQ-DEC2025"
    Title="MSMQ regressions reported after Dec 2025 cumulative updates"
    Severity="High (business systems)"
    Detected="MSMQ present + Dec 2025 CU detected + no OOB fix detected"
    Recommendation="If queue/write operations are failing, install the matching Dec 18, 2025 out-of-band update (KB5074976/KB5074975/KB5074974) from Microsoft Update Catalog or contact Microsoft Business Support. Generate a support bundle for escalation."
  })
} elseif ($msmq.Present -and $msmqOOB) {
  $risks.Add([pscustomobject]@{
    Id="MSMQ-OOB-PRESENT"
    Title="MSMQ OOB fix present"
    Severity="Info"
    Detected="MSMQ present + OOB fix detected"
    Recommendation="If issues persist, capture logs and escalate with support bundle."
  })
} elseif ($msmq.Present) {
  $risks.Add([pscustomobject]@{
    Id="MSMQ-PRESENT"
    Title="MSMQ installed"
    Severity="Info"
    Detected="MSMQ present"
    Recommendation="If messaging-dependent apps are failing, review MSMQ logs + service health and check for Dec 2025 known-issue KBs."
  })
}

# StartIsBack risk
if ($sib.Present -and (HasKB "KB5071546")) {
  $risks.Add([pscustomobject]@{
    Id="SIB-KB5071546"
    Title="StartIsBack present with KB5071546 (black/blank desktop reports)"
    Severity="Medium"
    Detected="StartIsBack present + KB5071546 installed"
    Recommendation="If you hit a black/blank desktop, update StartIsBack to the latest build or temporarily uninstall it. Only roll back KB5071546 if absolutely necessary (security tradeoff)."
  })
} elseif ($sib.Present) {
  $risks.Add([pscustomobject]@{
    Id="SIB-PRESENT"
    Title="StartIsBack installed"
    Severity="Info"
    Detected="StartIsBack present"
    Recommendation="Keep StartIsBack updated after Patch Tuesday cycles."
  })
}

# ESU enrollment wizard issue (consumer)
if (($osInfo.ProductName -match "Windows 10") -and -not (HasKB "KB5071959")) {
  $risks.Add([pscustomobject]@{
    Id="ESU-ENROLLMENT"
    Title="Windows 10 Consumer ESU enrollment wizard fix may be missing (KB5071959)"
    Severity="Info"
    Detected="Windows 10 detected; KB5071959 not observed in hotfix list"
    Recommendation="If ESU enrollment wizard fails with 'Something went wrong', install KB5071959 (OOB) and retry enrollment."
  })
}

# Collect artifacts
$systeminfoPath = Join-Path $artifactsDir "systeminfo.txt"
try { & systeminfo.exe /FO LIST | Out-File -FilePath $systeminfoPath -Encoding utf8 } catch { Add-RunError 'systeminfo' $_.Exception }

$hotfixPath = Join-Path $artifactsDir "hotfixes.txt"
try { ($kbs | Out-String) | Out-File -FilePath $hotfixPath -Encoding utf8 } catch { Add-RunError 'hotfixes.txt' $_.Exception }

$msmqSvcPath = Join-Path $artifactsDir "services_msmq.txt"
try { Get-Service -Name MSMQ -ErrorAction SilentlyContinue | Format-List * | Out-File $msmqSvcPath -Encoding utf8 } catch { Add-RunError 'services_msmq.txt' $_.Exception }

$evtxDir = Join-Path $artifactsDir "eventlogs"
Ensure-Dir $evtxDir
if ($CollectorLevel -ne 'Lite') {
  try { $evtx = Export-EventLogs -Dir $evtxDir -IncludeMSMQ:$msmq.Present } catch { Add-RunError 'Export-EventLogs' $_.Exception }
} else {
  $evtx = @()
  Write-Log 'CollectorLevel=Lite: skipping EVTX export.'
}

if ($IncludeMinidumps -and $CollectorLevel -eq 'Deep') {
  $dump = "C:\Windows\Minidump"
  if (Test-Path $dump) {
    $dst = Join-Path $artifactsDir "minidump"
    Ensure-Dir $dst
    Copy-Item -Path (Join-Path $dump "*") -Destination $dst -ErrorAction SilentlyContinue
  }
}

if ($IncludeMsinfo -and $CollectorLevel -eq 'Deep') {
  $nfo = Join-Path $artifactsDir "msinfo32.nfo"
  try { & msinfo32.exe /nfo $nfo /categories +all } catch {}
}

$report = @{
  Preflight = $preflight
  RunErrors = $script:RunErrors

  Tool = @{ Name="WinPatch Rapid Triage Kit"; Version="1.1.0" }
  Customer = $Customer
  Ticket = $Ticket
  OS = $osInfo
  InstalledKBs = $kbs
  KnownKBs = $Known
  MSMQ = $msmq
  StartIsBack = $sib
  EventLogs = $evtx
  Risks = $risks
}

if ($script:Redact) {
  # scrub likely-sensitive fields
  $report.Customer = ""
  $report.Ticket = ""
}

$reportJson = Join-Path $root "report.json"
$reportHtml = Join-Path $root "report.html"
Write-Json -Obj $report -Path $reportJson
Write-HtmlReport -Report $report -Path $reportHtml

# Build support bundle
$supportZip = Join-Path $root "support_bundle.zip"
if (-not $NoZip) {
  if (Test-Path $supportZip) { Remove-Item $supportZip -Force }
  Compress-Archive -Path (Join-Path $artifactsDir "*"), $reportJson, $reportHtml -DestinationPath $supportZip -CompressionLevel Optimal
  $hash = Get-FileHash -Path $supportZip -Algorithm SHA256
  $hash | ConvertTo-Json | Out-File (Join-Path $root "support_bundle.sha256.json") -Encoding utf8
}

Write-Host ""
Write-Host "[OK] WinPatch triage completed." -ForegroundColor Green
Write-Host "Output: $root"
Write-Host " - report.html"
Write-Host " - report.json"
if (-not $NoZip) { Write-Host " - support_bundle.zip" }
Write-Host ""
Write-Host "Tip: Run PowerShell as Administrator for more complete log exports." -ForegroundColor Yellow


# -------------------------
# Seats warning (non-blocking)
# -------------------------
try {
  if ($report -and $report.SeatsStatus -and $report.SeatsStatus.Warnings -and @($report.SeatsStatus.Warnings).Count -gt 0) {
    Write-Host ""
    Write-Host "Seat warnings (non-blocking):" -ForegroundColor Yellow
    foreach ($w in $report.SeatsStatus.Warnings) { Write-Host ("  - " + $w) -ForegroundColor Yellow }
  }
} catch {}
