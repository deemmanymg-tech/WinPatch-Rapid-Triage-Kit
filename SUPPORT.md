# Support — ReactedHQ


## Start Here (RUN ME FIRST)
Run `RUN_ME_FIRST.ps1` first. It launches the One‑Command Copier and copies the best command to your clipboard.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

Support email: **deemmanymg@gmail.com**

## What to include
- Windows version/build (from report.html or report.json)
- Symptom description + screenshots
- Attach **support_bundle.zip** if possible (or paste the top of report.json)

## Response expectations
Best-effort support. Typical response target: within 48 hours (not guaranteed).


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


For fastest help, read and follow: `SUPPORT_INTAKE.md`.

If you need to prove the kit is running cleanly, run the verification gate from the kit folder (where `WinPatchTriage.ps1` lives):

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RELEASE_GATE.ps1
```

Evidence files: `_parse.txt`, `_run.txt`, `_out_tree.txt`, `_log_tail.txt`.


Tip: run `COPY_SUPPORT_EMAIL.ps1` to copy a ready-to-paste support email body to your clipboard.
