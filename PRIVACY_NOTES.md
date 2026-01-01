# Privacy Notes — ReactedHQ

This kit can export diagnostic data and package it into ZIP files for escalation.

## What it may collect
- OS/build information, installed HotFix IDs (KBs)
- Selected Event Logs (EVTX)
- systeminfo output, MSMQ service info
- Optional (only when enabled): MSINFO32 output, minidumps, installed programs/services/network config, Windows Update log

## Your control
- Review **support_bundle.zip** before sharing externally.
- Use `-Redact` to reduce identifiers in reports.
- Keep optional collectors off unless needed.
