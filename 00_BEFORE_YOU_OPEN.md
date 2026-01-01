# Before You Open — ReactedHQ WinPatch Rapid Triage Kit (v1.6.1)


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

This guide is intentionally **baby-step**. Follow in order.

## 0) What this product is (and is not)
✅ It **diagnoses** patch-related problems and generates a **professional report + support bundle**.  
✅ It helps you identify whether the **matching Out-of-Band (OOB)** fix is installed.  
✅ It gives you safe next actions (restart services, open Microsoft Update Catalog links).  

❌ It does NOT silently install updates or do risky registry hacks.  
❌ It cannot guarantee your specific incident is fixed (every environment differs).  
But it *does* guarantee you’ll get clear evidence and next steps.

## 1) Download + Unzip
1. Download the ZIP you purchased.
2. Right-click the ZIP → **Properties**.
3. If you see **Unblock**, check it → **Apply**.
4. Right-click the ZIP → **Extract All…**
5. Extract to an easy folder, example:
   `C:\Temp\WinPatchKit`

## 2) Open PowerShell correctly
### Recommended (best success)
1. Press Start, type **PowerShell**
2. Right-click **Windows PowerShell** → **Run as administrator**
3. In PowerShell, go to the kit folder:
   ```powershell
   cd C:\Temp\WinPatchKit\WinPatchRapidTriageKit_v1_1
   ```

## 3) Allow script execution (safe, temporary)
Run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

That only affects the current PowerShell window.

## 4) Choose your run mode (CollectorLevel)
- **Lite** = fastest, least data, skips EVTX export
- **Standard** = recommended for incidents (exports key logs)
- **Deep** = only if support asks (allows msinfo/minidumps when enabled)

## Next: follow `CUSTOMER_MANUAL.md`.


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
