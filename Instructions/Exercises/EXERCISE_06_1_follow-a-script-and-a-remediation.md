---
redirect_from:
  - /Instructions/Labs/LAB_06_1_trace-a-platform-script-and-a-remediation.html
title: 'Exercise 6.1 – Follow a script and a remediation'
lab:
    title: 'Exercise 6.1 – Follow a script and a remediation'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 6.1 – Follow a script and a remediation

**Estimated time:** 40 minutes

**Goal:** Trace a platform script and a remediation from assignment to result on CL3 – the platform script after an IME restart, the remediation on demand – and read the outcome in the portal.

### Part A – Platform script after an IME restart

1. In the Intune admin center, go to Devices → Scripts and remediations → Platform scripts → Add → Windows 10 and later and add the platform script `flaneX-Folder` with `createtestfolder.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles), assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Run this script using the logged on credentials | No (runs as System) |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell host | No |

2. In `Detect-LabKey.ps1` and `Remediate-LabKey.ps1` from the Labfiles, change `flaneX` in the registry key to your user name (for example `flane3`). Read through both: which exit code stands for compliant, and which one triggers the remediation?
3. Under Devices → Scripts and remediations → Remediations, select **Create script package** and create `flaneX-Reg` with both scripts, assigned to `studentXdevices` on the schedule **Hourly**:

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. On CL3, restart the IME from an elevated PowerShell.

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

5. Trace `flaneX-Folder` in `IntuneManagementExtension.log` and `AgentExecutor.log`.
6. Still on CL3, look for `HKLM\SOFTWARE\flaneX\Lab`. It isn't there yet: the IME restart ran the platform script, not the remediation, and `flaneX-Reg` is waiting for its schedule.

### Part B – Remediation on demand

7. Skip the wait: in the Intune admin center, open Devices → All devices → `CL3-yourname` → … → **Run remediation** and pick `flaneX-Reg`.
8. On CL3, trace the run in `HealthScripts.log` under `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` – detection, remediation, detection again – and confirm that `HKLM\SOFTWARE\flaneX\Lab` now exists.
9. In the Intune admin center under Remediations → `flaneX-Reg` → Device status, add the columns for the detection output before and after the remediation.
10. Finally, compare the device status of both scripts for CL3 in the Intune admin center.

### Checkpoint

- [ ] CL3 has `C:\TestFolder`
- [ ] `AgentExecutor.log` shows the exit code of `flaneX-Folder`
- [ ] After the IME restart, `HKLM\SOFTWARE\flaneX\Lab` is still missing
- [ ] The on-demand run found the issue and fixed it – `HKLM\SOFTWARE\flaneX\Lab` exists on CL3 without waiting for the schedule
- [ ] Device status reads **Issue fixed** and shows the output of both detection runs

### Good to know

- **Exit codes and retries:** detection exits with `1` when the key is missing, and only exit code `1` triggers the remediation. A failing platform script is retried three times at the next three IME check-ins; after that it stays failed until the script or the policy changes.
- **What an IME restart runs:** pending platform scripts, but not remediations – those follow their schedule or run on demand. If the hourly schedule beat you to it and the key already exists in step 6, trace that run in `HealthScripts.log` instead and still start the on-demand run in step 7.
- **Detection output:** whatever a detection script writes with `Write-Output` lands in the device status columns. Keep it short and readable – the helpdesk sees it first.

**Why 64-bit:** a 32-bit PowerShell host redirects `HKLM\SOFTWARE` to `HKLM\SOFTWARE\WOW6432Node`, so the remediation would fix a different key from the one you check.
