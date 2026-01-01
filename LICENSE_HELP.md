# License Activation (Offline) — ReactedHQ


## Start Here (RUN ME FIRST)
Run `RUN_ME_FIRST.ps1` first. It launches the One‑Command Copier and copies the best command to your clipboard.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

Activation is **optional** and **does not block usage**.
It helps your support request get handled faster by confirming your tier.

## What you need
- **Receipt ID** (from Gumroad/Payhip/Ko-fi order email or receipt page)
- **Purchaser email** (the email used at checkout)

## Activate
1) Open PowerShell in the kit folder
2) Run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ACTIVATE_LICENSE.ps1 -LicenseTier "Standard"
```
3) Enter receipt ID + purchaser email when prompted.

This will create: `license.json` in the kit folder.

## If you automate (no prompts)
```powershell
.\WinPatchTriage.ps1 -LicenseTier "MSP Team" -ReceiptId "YOUR_RECEIPT_ID" -PurchaserEmail "you@example.com" -LicenseKey "YOUR_KEY"
```

## Privacy
The license file stores:
- tier, receipt id, purchaser email, license key
It does not collect system data.


## One‑Command Copier (reduces mistakes)
Run `ONE_COMMAND_COPIER.ps1` to generate the best single command for this machine and **copy it to your clipboard**.
Example:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ONE_COMMAND_COPIER.ps1 -PreferWizard
```


## Shared mailbox (recommended for teams)
For Standard/MSP Team, we recommend activating using a shared mailbox like:
- `it@yourcompany.com`

Benefits:
- one consistent purchaser email across your techs
- easier internal tracking

### Optional: seats.json (warn-only)
To keep licensing clean, you can list technician seats (email preferred). This does **not** block the tool.

Create/update seats file:
```powershell
.\ADD_TECH_SEATS.ps1 -LicenseTier "MSP Team"
```

If seats exceed your tier limit, the tool shows a **warning** but continues running.
