# CUSTOMER MANUAL — ReactedHQ WinPatch Rapid Triage Kit (v1.6.1)


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

Support: **deemmanymg@gmail.com**

---

## What you will see when you run it
When you run the tool, it creates an output folder (default: `WinPatchTriage_Output`) containing:

- `report.html` — a client‑friendly report (open in browser)
- `report.json` — full machine‑readable results
- `support_bundle.zip` — a single ZIP you can attach to support tickets
- `triage.log` — everything the tool did (helps troubleshooting)

If you run the wizard, it will create:
- `WinPatchTriage_Output\before\...`
- `WinPatchTriage_Output\after\...`

---

## Part A — Run the tool (normal mode)

### A1) Run triage (recommended)
1) Open **PowerShell as Administrator**
2) Go into the kit folder
3) Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -CollectorLevel Standard -OutputDir .\WinPatchTriage_Output -Customer "YOUR_CUSTOMER" -Ticket "YOUR_TICKET"
```

### A2) Open the report
1) Open:
`WinPatchTriage_Output\report.html`
2) Look for:
- **RiskLevel**
- **Issues Found**
- **Recommended next steps**

### A3) If it shows “OOB missing”
If the report says the matching **Out-of-Band (OOB)** update is missing:

1) Run:
```powershell
.\OPEN_OOB_LINKS.ps1
```
2) Your browser opens Microsoft Update Catalog searches.
3) Download and install the KB that matches your OS.
4) Reboot if prompted.
5) Run triage again (A1) and compare results.

---

## Part B — The easiest path (Fix Wizard)
If you want the tool to walk you through *before → actions → after*:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\FIX_WIZARD.ps1 -CollectorLevel Standard -OutputDir .\WinPatchTriage_Output -Customer "YOUR_CUSTOMER" -Ticket "YOUR_TICKET"
```

Wizard steps:
1) Runs triage (BEFORE)
2) Tells you what the report flags
3) Opens OOB links if needed
4) Offers safe restarts
5) Runs triage (AFTER)
6) Compares the results and tells you what changed

---

## Part C — Troubleshooting

### C1) “Scripts are disabled”
Run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

### C2) EVTX export fails / Access denied
Use Lite mode:
```powershell
# Make sure you're in the kit folder first
Set-Location $PSScriptRoot
.\WinPatchTriage.ps1 -CollectorLevel Lite -OutputDir .\WinPatchTriage_Output
```

### C3) Output folder won’t delete / is locked
Close the open browser tab showing report.html, then run:
```powershell
.\RESET_TO_CLEAN_BASE.ps1 -OutputDir .\WinPatchTriage_Output
```

---

## Part D — How to know if you are “fixed”
This kit cannot magically prove your application is perfect, but it can prove:

✅ The matching OOB KB is now installed  
✅ MSMQ service is running and error rate decreased  
✅ RiskLevel and Issues Count dropped between runs  

**Final confirmation is always:** your messaging app / workflow works normally again.

Use:
```powershell
.\COMPARE_REPORTS.ps1 -Before .\WinPatchTriage_Output\before\report.json -After .\WinPatchTriage_Output\after\report.json
```

---

## When to email support
Email **deemmanymg@gmail.com** and attach:
- `support_bundle.zip`
- your symptom description + screenshots


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


## Where outputs go
By default, outputs are saved to:
- `Desktop\ReactedHQ_WinPatch_Output\<timestamp>\` (when using RUN_ME_FIRST / double-click)
- `WinPatchTriage_Output\` under your current folder (when running WinPatchTriage.ps1 directly without -OutputDir)

The path is printed and **copied to clipboard** automatically.
