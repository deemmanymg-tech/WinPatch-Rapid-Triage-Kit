# Quickstart — ReactedHQ WinPatch Rapid Triage Kit


## Easiest start (no typing)
After unzipping, double-click:
- `DOUBLE_CLICK_ME.cmd`

It will request Administrator via UAC (recommended). If you cancel, it runs in LIMITED mode.


## Start Here (RUN ME FIRST)
Run `RUN_ME_FIRST.ps1` first. It launches the One‑Command Copier and copies the best command to your clipboard.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

## Run (Admin recommended)
```powershell
# Make sure you're in the kit folder (the folder that contains WinPatchTriage.ps1)
Set-Location $PSScriptRoot  # or: Set-Location "C:\path\to\WinPatchRapidTriageKit_v1_1"
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -OutputDir .\out -Customer "ACME" -Ticket "INC-12345"
```

## Outputs
- out\report.html
- out\report.json
- out\support_bundle.zip (+ SHA)

## Optional safe actions
```powershell
.\ApplyMitigation.ps1 -RestartMSMQ
.\ApplyMitigation.ps1 -RestartExplorer
.\ApplyMitigation.ps1 -OpenWindowsUpdate
```

## Support
Email **deemmanymg@gmail.com** and attach out\support_bundle.zip.


## Collector levels
- **Lite**: skips EVTX export (fastest / least data)
- **Standard**: exports key event logs (recommended)
- **Deep**: allows MSINFO32/minidumps when switches enabled

Example:
```powershell
.\WinPatchTriage.ps1 -OutputDir .\out -CollectorLevel Standard
```


## One‑Command Copier (reduces mistakes)
Run `ONE_COMMAND_COPIER.ps1` to generate the best single command for this machine and **copy it to your clipboard**.
Example:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ONE_COMMAND_COPIER.ps1 -PreferWizard
```


## Verify your download (optional, recommended for IT teams)
A **SHA-256 checksum** is a file “fingerprint.” It lets you confirm the ZIP you downloaded is exactly the file the publisher uploaded.

### How to verify on Windows
1) Download the product ZIP.
2) Compute its SHA-256 hash:

**PowerShell**
```powershell
Get-FileHash .\ReactedHQ_WinPatchRapidTriageKit_v1_6_1*.zip -Algorithm SHA256
```

**Command Prompt**
```bat
certutil -hashfile ReactedHQ_WinPatchRapidTriageKit_v1_6_1.zip SHA256  # replace with your exact ZIP filename
```

3) Compare the output to the hash shown in the included `*.sha256.txt` file (or the value posted on the product page).
If it matches: ✅ verified.
If it doesn’t: re-download the ZIP (or contact support).


## Licensing & activation (optional)
- Your **license key is unique** per purchase (derived from Tier + Receipt ID + Purchaser Email).
- **Activation does not block the tool.** The kit runs fine without activation.
- Activation is recommended for faster support verification.

Activate (optional):
```powershell
.\ACTIVATE_LICENSE.ps1 -LicenseTier "Standard"
```


## Verification (Release Gate)
Run this from the kit folder (where `WinPatchTriage.ps1` lives):

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RELEASE_GATE.ps1
```

Evidence files: `_parse.txt`, `_run.txt`, `_out_tree.txt`, `_log_tail.txt`.

## Need help?
Email **deemmanymg@gmail.com** and follow `SUPPORT_INTAKE.md` so we can resolve it quickly.


## Where outputs go
- If you start via **DOUBLE_CLICK_ME.cmd** or **RUN_ME_FIRST.ps1**: outputs default to  
  `Desktop\ReactedHQ_WinPatch_Output\<timestamp>\` (path is printed and copied to clipboard).
- If you run **WinPatchTriage.ps1 directly**:
  - Default output folder is `.\WinPatchTriage_Output` under your *current* directory.
  - Recommended: always pass `-OutputDir .\out` (creates/uses an `out` folder next to the kit).
