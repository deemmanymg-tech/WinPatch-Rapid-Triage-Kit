# Support (Fast Help) — ReactedHQ

Email: **deemmanymg@gmail.com**

To get help quickly and avoid back-and-forth, send **one email** with the items below.

## Subject line (copy/paste)
`WinPatch Help — <Your Company> — <Ticket/Case ID> — <Short Symptom>`

Example:  
`WinPatch Help — ACME — INC-12345 — MSMQ service not running`

## Attachments (best → acceptable)
**Best (1 attachment):**
- `support_bundle.zip`

**If you cannot attach that:**
- `report.json`
- `triage.log`
- Screenshot of the “Risk Assessment” section from `report.html`

## Include these details in the email body
1) What symptom you have (MSMQ failing, black desktop, etc.)
2) What you expected to happen
3) What you ran (copy/paste)
4) Whether you rebooted after updates
5) Whether this is a server or workstation
6) Any security restrictions (locked-down endpoint, no admin rights, etc.)

## If it won’t run at all
1) Run SelfTest:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\WinPatchTriage.ps1 -SelfTest -OutputDir .\WinPatchTriage_Output
```
2) Attach `selftest_report.json` + `triage.log`

---

# What I will do with your report
- Read RiskLevel + Issues
- Identify likely patch/OOB/service condition
- Provide **a step-by-step safe action plan**
- If escalation is needed: tell you exactly what to send to Microsoft/vendor support



Tip: run `COPY_SUPPORT_EMAIL.ps1` to copy a ready-to-paste support email body to your clipboard.
