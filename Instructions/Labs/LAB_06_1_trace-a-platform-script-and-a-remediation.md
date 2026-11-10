---
title: 'Lab 6.1 – Trace a platform script and a remediation'
lab:
    title: 'Lab 6.1 – Trace a platform script and a remediation'
    module: 'Day 2 – Apps, protect, support'
---

# Lab 6.1 – Trace a platform script and a remediation

**Estimated time:** 40 minutes

**Goal:** Follow a platform script and a remediation from the assignment to the result on CL3 – the platform script after an IME restart, the remediation on demand – and read the result in the portal.

### Part A – Platform script after an IME restart

1. Intune admin center → Devices → Scripts and remediations → Platform scripts → Add → Windows 10 and later: platform script `flaneX-Folder` with `createtestfolder.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles), assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Run this script using the logged on credentials | No (runs as System) |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell host | No |

2. In `Detect-LabKey.ps1` and `Remediate-LabKey.ps1` from the Labfiles, replace `flaneX` in the registry key with your user name (for example `flane3`). Read both: which exit code means compliant, which one starts the remediation?
3. Intune admin center → Devices → Scripts and remediations → Remediations → **Create script package**: `flaneX-Reg` with both scripts, assigned to `studentXdevices`, schedule **Hourly**:

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. CL3, elevated PowerShell: restart the IME.

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

5. Follow `flaneX-Folder` in `IntuneManagementExtension.log` and `AgentExecutor.log`.
6. CL3: check `HKLM\SOFTWARE\flaneX\Lab`. The key is still missing – the IME restart ran the platform script, not the remediation. `flaneX-Reg` waits for its schedule.

### Part B – Remediation on demand

7. Do not wait for the schedule: Intune admin center → Devices → All devices → `CL3-yourname` → … → **Run remediation** → `flaneX-Reg`.
8. CL3: follow the run in `HealthScripts.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`: detection, remediation, detection again. Check that `HKLM\SOFTWARE\flaneX\Lab` exists now.
9. Intune admin center → Remediations → `flaneX-Reg` → Device status: add the columns for the detection output before and after the remediation.
10. Intune admin center: compare the device status of both scripts for CL3.

### Checkpoint

- [ ] `C:\TestFolder` exists on CL3
- [ ] Exit code of `flaneX-Folder` found in `AgentExecutor.log`
- [ ] After the IME restart: `HKLM\SOFTWARE\flaneX\Lab` still missing
- [ ] Run on demand: issue found, then fixed – `HKLM\SOFTWARE\flaneX\Lab` exists on CL3 without waiting for the schedule
- [ ] Device status shows **Issue fixed** with the output of both detection runs

**Note:** Detection exits with `1` when the key is missing – only exit code `1` starts the remediation. A platform script that fails is retried three times at the next three IME check-ins, then it stays failed until the script or the policy changes.

**Note:** Restarting the IME runs pending platform scripts, but not remediations – they run on their schedule or on demand. If the hourly schedule was faster than you and the key already exists in step 6, follow that run in `HealthScripts.log` instead and still start the on-demand run in step 7.

**Note:** Everything a detection script writes with `Write-Output` shows up in the device status columns. Write a short, readable state – it is what the helpdesk sees first.

**Why 64-bit:** A 32-bit PowerShell host writes `HKLM\SOFTWARE` to `HKLM\SOFTWARE\WOW6432Node`. The remediation would then fix a different key than the one you check.
