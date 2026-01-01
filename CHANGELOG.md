## 1.6.1 (2025-12-31)
- Fixed WinPatchTriage.ps1 param-block corruption that could trigger PowerShell parse errors (stray `n tokens).
- Fixed HTML report generator conditional rendering to avoid: `if : The term 'if' is not recognized`.
- Added RELEASE_GATE.ps1 end-to-end verification script (parse/run/outputs/zip/HTML+JSON sanity).
- Added SUPPORT_INTAKE.md (email template + required attachments).
- Expanded NEXT_STEPS.md with symptom-based baby steps.
- Added warn-only seats.json helper (ADD_TECH_SEATS.ps1) + SeatsStatus in report.
- Added SHA-256 checksum explanation + verification commands to customer docs.
- Added RUN_ME_FIRST.ps1 as primary entrypoint (launches One‑Command Copier in wizard mode).

# Changelog

## 1.1.0 (2025-12-31)
- Updated KB matrix to verified Dec 2025 wave:
  - CUs: KB5071546 / KB5071544 / KB5071543
  - OOB fixes: KB5074976 / KB5074975 / KB5074974
  - ESU enrollment fix: KB5071959
- Added Export-SupportBundle.ps1 with privacy-safe defaults.
- Added -Redact switch to reduce sensitive identifiers in reports.

## 1.0.0 (2025-12-31)
- Initial release: KB detection, MSMQ & StartIsBack presence checks, event log export, HTML/JSON report, support bundle ZIP.
