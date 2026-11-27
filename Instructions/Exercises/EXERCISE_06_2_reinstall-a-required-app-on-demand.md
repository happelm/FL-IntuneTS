---
redirect_from:
  - /Instructions/Labs/LAB_06_2_force-the-reinstall-of-a-required-app.html
title: 'Exercise 6.2 – Reinstall a required app on demand'
lab:
    title: 'Exercise 6.2 – Reinstall a required app on demand'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 6.2 – Reinstall a required app on demand

**Estimated time:** 25 minutes

**Goal:** Hand the helpdesk a way to reinstall a required Win32 app on a single device – using a remediation that runs on demand.

**Background:** Intune offers no repair action for Win32 apps. For a required app, Reinstall in the Company Portal does nothing as long as detection is positive, and Uninstall never reaches the device. The one lever left is the detection rule: take away what detection looks for, and the IME installs the app again.

1. On CL3, write down the date of `C:\Windows\CMTrace.exe` – the detection file of `flaneX-CMTrace` from Exercise 5.1.
2. Download `Detect-ReinstallCMTrace.ps1` and `Remediate-ReinstallCMTrace.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles).
3. In the Intune admin center, go to Devices → Scripts and remediations → Remediations, select **Create script package** and create `flaneX-Reinstall-CMTrace` with both scripts.

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. On the Assignments page, choose **no group** – this remediation only ever runs on demand.
5. Open Devices → All devices → `CL3-yourname` → … → **Run remediation** and pick `flaneX-Reinstall-CMTrace`.
6. On CL3, trace `HealthScripts.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`: the detection script exits with `1`, the remediation runs and `CMTrace.exe` disappears.
7. Roughly three minutes later, the IME restarts. Trace `AppWorkload.log`: `flaneX-CMTrace` isn't detected, the install command runs and detection succeeds.
8. Look at the date of `C:\Windows\CMTrace.exe` once more, and at the install status in the Intune admin center.

### Checkpoint

- [ ] `HealthScripts.log` shows detection with an issue and the remediation run
- [ ] `AppWorkload.log` shows `flaneX-CMTrace` being reinstalled
- [ ] `CMTrace.exe` carries a newer date than in step 1
- [ ] You can explain why this remediation must never be assigned to a group

### Good to know

- **What the remediation cleans up:** it deletes the GRS keys under `HKLM\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps`. These keys hold the re-evaluation schedule of the Win32 apps; once they are gone, the IME runs detection at its next check-in instead of waiting. The line resets the schedule for every app on the device: apps with a positive detection stay untouched, failed apps get retried sooner. Deleting `LastFullReportTimeUtc` under `...\Win32Apps\Reporting` turns the next status report into a full one – without it the reinstall still happens, but the Intune admin center shows it much later.

### Background

- **Why the delay:** the remediation runs inside the IME. Restarting the service immediately would kill the script before its result is reported, so a separate process waits three minutes and then restarts the IME.
- **Why no assignment:** assigned to a group, the remediation would delete the detection file on every scheduled run and reinstall the app over and over.
