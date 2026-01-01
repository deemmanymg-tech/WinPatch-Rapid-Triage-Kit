# Troubleshooting — ReactedHQ


## Start Here (RUN ME FIRST)
Run `RUN_ME_FIRST.ps1` first. It launches the One‑Command Copier and copies the best command to your clipboard.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

## Script blocked
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

## .\WinPatchTriage.ps1 is not recognized
This means PowerShell can’t see the script in your current folder (common when you’re still in `C:\Windows\System32`).

Fix:

```powershell
Set-Location "C:\path\to\WinPatchRapidTriageKit_v1_1"
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -OutputDir .\out -Customer "ACME" -Ticket "INC-12345"
```

## EVTX export fails / Access denied
- Run PowerShell **as Administrator**, or use:
```powershell
.\WinPatchTriage.ps1 -CollectorLevel Lite
```

## Bundle too large
Use Lite or Standard (avoid Deep unless needed):
```powershell
.\WinPatchTriage.ps1 -CollectorLevel Standard
```

## Need OOB links quickly
```powershell
.\OPEN_OOB_LINKS.ps1
```

## Support
Email deemmanymg@gmail.com and attach `support_bundle.zip` if possible.


## Optional: License activation
Run `ACTIVATE_LICENSE.ps1` to create `license.json` using your receipt ID. This does **not** block usage; it helps support validate your tier faster.


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


## Need help?
Email **deemmanymg@gmail.com** and follow `SUPPORT_INTAKE.md` so we can resolve it quickly.


## Verification (Release Gate)
Run this from the kit folder (the folder that contains `WinPatchTriage.ps1`):

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RELEASE_GATE.ps1
```

Evidence files: `_parse.txt`, `_run.txt`, `_out_tree.txt`, `_log_tail.txt`.
