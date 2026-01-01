# WinPatch Rapid Triage Kit (v1.6.1)


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

A lightweight **MSP-friendly Windows patch triage & support bundle generator** focused on the **December 2025** Windows patch wave.

## What it targets (Dec 2025)

**Reported MSMQ regressions** after the Dec 9, 2025 cumulative updates:
- Windows 10 ESU: **KB5071546**
- Windows Server 2019 / Win10 Ent LTSC 2019: **KB5071544**
- Windows Server 2016 / Win10 Ent LTSB 2016: **KB5071543**

Microsoft released **out-of-band (OOB) fixes on Dec 18, 2025**:
- Windows 10 ESU: **KB5074976**
- Windows Server 2019 / LTSC 2019: **KB5074975**
- Windows Server 2016 / LTSB 2016: **KB5074974**

Windows 10 Consumer ESU enrollment wizard failures were addressed by:
- **KB5071959** (Nov 11, 2025 OOB)

Sources: Microsoft Support KBs + reporting. (See “References” below.)

## Quickstart (PowerShell)

1) Unzip the kit  
2) Open **PowerShell as Administrator** (recommended)  
3) Run:

> **Important:** run the command from the kit folder (the folder that contains `WinPatchTriage.ps1`).
> If you see `'.\WinPatchTriage.ps1' is not recognized`, you’re not in the right folder (often `C:\Windows\System32`).
> Use `Set-Location "C:\path\to\WinPatchRapidTriageKit_v1_1"` first.


```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -OutputDir .\out -Customer "ACME" -Ticket "INC-12345"
```

Optional collectors:

```powershell
.\WinPatchTriage.ps1 -OutputDir .\out -IncludeMsinfo -IncludeMinidumps
```

Privacy / redaction mode:

```powershell
.\WinPatchTriage.ps1 -OutputDir .\out -Redact
```

### Optional guided actions (safe-by-default)

```powershell
.\ApplyMitigation.ps1 -OpenWindowsUpdate
.\ApplyMitigation.ps1 -RestartExplorer
.\ApplyMitigation.ps1 -RestartMSMQ
```

### Separate support bundle (optional)

```powershell
.\Export-SupportBundle.ps1 -TriageOutputPath .\out -OutDir .\out
```

Add optional collectors (off by default):

```powershell
.\Export-SupportBundle.ps1 -TriageOutputPath .\out -OutDir .\out -IncludeServices -IncludeNetwork
```

## Guardrails

- Diagnostics-first: **no registry hacks**, **no forced uninstall**, **no silent patch downloads**
- StartIsBack behavior is based on public reports; Microsoft KB text for KB5071546 focuses on other changes, so treat the exact cause as “reported/observed” rather than an official Microsoft admission.

## References
- Microsoft KB5071546 (Dec 9, 2025) and KB5074976 (Dec 18, 2025 OOB).  
- Microsoft KB5071544 / KB5071543 (Dec 9, 2025) and the OOB fixes KB5074975 / KB5074974 (Dec 18, 2025).  
- Public reporting on StartIsBack + KB5071546 symptoms and MSMQ impacts.



## Support
Email **deemmanymg@gmail.com** (attach `support_bundle.zip` if possible).



## Verification (Release Gate)
Run this from the kit folder (where `WinPatchTriage.ps1` lives):

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RELEASE_GATE.ps1
```

Evidence files: `_parse.txt`, `_run.txt`, `_out_tree.txt`, `_log_tail.txt`.

## Policies
See: `REFUND_POLICY.md`, `PRIVACY_NOTES.md`, `DISCLAIMERS.md`, `LICENSE.txt`.


## Troubleshooting
See `TROUBLESHOOTING.md`.


## Open OOB KB links
Run `OPEN_OOB_LINKS.ps1` to open Microsoft Update Catalog search pages.


## Customer Manual
Start here: `00_BEFORE_YOU_OPEN.md` then `CUSTOMER_MANUAL.md`.


## Guided Fix Wizard
Run `FIX_WIZARD.ps1` for an end-to-end guided flow.


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


## For sellers
If you are reselling/redistributing via marketplaces, see `SELLER_TEMPLATES.md` for copy/paste buyer messages and support replies.


## Where outputs go
- If you start via **DOUBLE_CLICK_ME.cmd** or **RUN_ME_FIRST.ps1**: outputs default to  
  `Desktop\ReactedHQ_WinPatch_Output\<timestamp>\` (path is printed and copied to clipboard).
- If you run **WinPatchTriage.ps1 directly**:
  - Default output folder is `.\WinPatchTriage_Output` under your *current* directory.
  - Recommended: always pass `-OutputDir .\out` (creates/uses an `out` folder next to the kit).
