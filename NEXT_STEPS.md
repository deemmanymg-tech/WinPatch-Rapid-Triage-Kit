# NEXT_STEPS — What to do when issues are detected (safe)

This tool is designed to cover the most common “Dec 2025 patch wave” scenarios.

## If MSMQ is present AND the report says OOB is missing
1) Install the matching OOB update from Microsoft Update Catalog (use OPEN_OOB_LINKS.ps1)
2) Reboot if prompted
3) Restart MSMQ service and dependent services (ApplyMitigation.ps1 offers safe restarts)
4) Re-run WinPatchTriage.ps1
5) Compare reports to confirm improvements

## If StartIsBack is detected AND KB5071546 is present
1) Update StartIsBack to the latest compatible version (vendor guidance)
2) If symptoms persist (black/blank desktop), consider uninstalling StartIsBack temporarily
3) Reboot
4) Re-run WinPatchTriage.ps1 and confirm the warning no longer triggers

## If nothing is flagged but you still have an outage
1) Open report.html and check RecentErrors
2) Use support_bundle.zip to escalate to vendor/Microsoft
3) Run in Standard mode (or Deep only if support requests)


---

# Symptom-based fixes (baby-step)

> Safety note: This kit prefers **safe, reversible actions** and **evidence collection**.  
> It does **not** force-install updates. It opens links and guides you.

## If your symptom is: MSMQ (messages failing / service crashes / queues stuck)

1) Start with the guided flow:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

2) In the report, check **MSMQ**:
- If `MSMQ.Present = false`: MSMQ is not installed (your app may be using something else).
- If present but unhealthy: the report will show issues (service not running, recent errors).

3) Safe actions you can take (guided in ApplyMitigation.ps1):
- Restart MSMQ service in a maintenance window
- Export logs + generate support bundle

4) After changes:
- Reboot if Windows Update says pending reboot
- Re-run `FIX_WIZARD.ps1` and confirm RiskLevel and MSMQ status improved

## If your symptom is: Black/blank desktop after a patch (Start menu/shell issues)

1) Run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

2) Check “StartIsBack” section:
- If StartIsBack installed **and** “AtRisk = true”: follow vendor guidance to update StartIsBack.
- If you are testing: temporarily remove/disable the shell add-on and reboot to confirm.

3) After the change:
- Re-run triage and confirm the issue no longer appears as “AtRisk”.

## If your symptom is: “It won’t run” / “Access denied” / “script blocked”

1) Run SelfTest first:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -SelfTest -OutputDir .\WinPatchTriage_Output
```

2) If not admin:
- Right-click PowerShell → **Run as administrator**
- Or use Lite mode:
```powershell
.\WinPatchTriage.ps1 -CollectorLevel Lite -OutputDir .\WinPatchTriage_Output
```

3) If scripts are blocked:
- Right-click the ZIP → Properties → **Unblock**
- Or run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

## If your symptom is: “Not sure what changed” / “Did it fix anything?”

Use the BEFORE/AFTER compare:
```powershell
.\FIX_WIZARD.ps1 -CollectorLevel Standard -OutputDir .\WinPatchTriage_Output
```

The wizard writes BEFORE and AFTER reports and compares:
- RiskLevel
- Issue count
- MSMQ health
- Patch state signals

If risk stays High/Critical, attach `support_bundle.zip` and email deemmanymg@gmail.com.
