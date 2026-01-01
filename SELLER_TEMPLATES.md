# Seller Templates — ReactedHQ

These are copy/paste templates to reduce support emails and refunds.  
Support email: **deemmanymg@gmail.com**

---

## Gumroad “Message to buyer” (auto-send)

**Subject:** ReactedHQ WinPatch Kit — Start Here (RUN ME FIRST)

**Message:**
- Download and unzip the product.
- Open PowerShell (recommended: **Run as Administrator**).
- Run this first:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

### If you need help (fast support)
Email **deemmanymg@gmail.com** and follow **SUPPORT_INTAKE.md** inside the download.  
Best attachment: **support_bundle.zip** (created by the tool).

### Licensing (optional)
- Your license key is **unique per purchase**.
- **Activation does not block the tool** (it runs fine without activation).
- Activation is mainly for faster support verification:

```powershell
.\ACTIVATE_LICENSE.ps1 -LicenseTier "Standard"
```

### Teams / MSPs
Use a shared mailbox like **it@yourcompany.com** for activation so multiple techs can work smoothly.

---

## Fiverr “Delivery message”

Thanks for your order — here’s your ReactedHQ WinPatch Kit.

### Start here
1) Download and unzip
2) PowerShell → Run as Admin (recommended)
3) Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1
```

### If your environment is locked down
Run SelfTest:
```powershell
.\WinPatchTriage.ps1 -SelfTest -OutputDir .\WinPatchTriage_Output
```

### Need help?
Email **deemmanymg@gmail.com** and follow **SUPPORT_INTAKE.md** inside the kit.  
Attach **support_bundle.zip** if possible.

### License note
Activation is optional and never blocks usage. Your key is unique per purchase.

---

## Reddit pinned comment (short)

```text
If you’re fighting the patch/MSMQ/shell mess, I built a small triage kit that generates an HTML report + support_bundle.zip.

Start:
Set-ExecutionPolicy -Scope Process Bypass -Force
.\RUN_ME_FIRST.ps1

Support: deemmanymg@gmail.com (attach support_bundle.zip)
Activation is optional + non-blocking. Key is unique per purchase.
```

---

## Support auto-reply (copy/paste)

**Subject:** Re: WinPatch Help — Please reply with bundle

**Body:**
Thanks — I can help fast. Please reply with:

**Best:** attach `support_bundle.zip`  
If you can’t: attach `report.json` + `triage.log` + screenshot of Risk Assessment.

Also include:
1) Symptom (MSMQ down / black desktop / etc.)
2) Whether you ran PowerShell as Admin
3) Whether a reboot is pending
4) What command you ran (copy/paste)

Once I have that, I’ll send you a step-by-step safe action plan.


Seller note: For non-technical buyers, tell them to unzip and double-click `DOUBLE_CLICK_ME.cmd` (report opens automatically; output path is copied to clipboard).
