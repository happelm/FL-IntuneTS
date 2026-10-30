---
title: 'Lab 6.1 – Trace a platform script and a remediation'
lab:
    title: 'Lab 6.1 – Trace a platform script and a remediation'
    module: 'Day 2 – Apps, protect, support'
---

# Lab 6.1 – Trace a platform script and a remediation

**Estimated time:** 40 minutes

**Goal:** Follow a platform script and a remediation from the assignment to the result on CL3 – on the schedule and on demand – and read the result in the portal.

### Part A – Platform script and remediation on the schedule

1. Intune admin center → Devices → Scripts and remediations → Platform scripts → Add → Windows 10 and later: platform script `etcX-Folder` with `createtestfolder.ps1` from the [Labfiles](https://github.com/happelm/MDDMI-TS/tree/main/Labfiles), assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Run this script using the logged on credentials | No (runs as System) |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell host | No |

2. In `Detect-LabKey.ps1` and `Remediate-LabKey.ps1` from the Labfiles, replace `etcX` with your prefix. Read both: which exit code means compliant, which one starts the remediation?
3. Intune admin center → Devices → Scripts and remediations → Remediations → **Create script package**: `etcX-Reg` with both scripts, assigned to `studentXdevices`, schedule **Hourly**:

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. CL3, elevated PowerShell: restart the IME.

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

5. Follow `etcX-Folder` in `IntuneManagementExtension.log` and `AgentExecutor.log`.
6. Follow `etcX-Reg` in `HealthScripts.log`: detection, remediation, detection again.
7. Intune admin center: compare the device status of both scripts for CL3.

### Part B – Remediation on demand

8. CL3, elevated PowerShell: break what `etcX-Reg` fixed.

   ```powershell
   Remove-Item -Path 'HKLM:\SOFTWARE\etcX\Lab' -Recurse -Force
   ```

9. Do not wait for the schedule: Intune admin center → Devices → All devices → `CL3-yourname` → … → **Run remediation** → `etcX-Reg`.
10. CL3: follow the run in `HealthScripts.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` and check that the key is back.
11. Intune admin center → Remediations → `etcX-Reg` → Device status: add the columns for the detection output before and after the remediation.

### Checkpoint

- [ ] `C:\TestFolder` exists on CL3
- [ ] Exit code of `etcX-Folder` found in `AgentExecutor.log`
- [ ] `etcX-Reg`: issue found, then fixed – `HKLM\SOFTWARE\etcX\Lab` exists on CL3
- [ ] Run on demand: `HKLM\SOFTWARE\etcX\Lab` deleted and back again, without waiting for the schedule
- [ ] Device status shows **Issue fixed** with the output of both detection runs

**Note:** Detection exits with `1` when the key is missing – only exit code `1` starts the remediation. A platform script that fails is retried three times at the next three IME check-ins, then it stays failed until the script or the policy changes.

**Note:** Everything a detection script writes with `Write-Output` shows up in the device status columns. Write a short, readable state – it is what the helpdesk sees first.

**Why 64-bit:** A 32-bit PowerShell host writes `HKLM\SOFTWARE` to `HKLM\SOFTWARE\WOW6432Node`. The remediation would then fix a different key than the one you check.
