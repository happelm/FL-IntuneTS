---
redirect_from:
  - /Instructions/Labs/LAB_12_1_troubleshoot-laps-and-epm.html
title: 'Exercise 12.1 – Troubleshoot LAPS and EPM'
lab:
    title: 'Exercise 12.1 – Troubleshoot LAPS and EPM'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 12.1 – Troubleshoot LAPS and EPM

**Estimated time:** 60 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Read a Windows LAPS processing cycle in the event log, repair a policy that manages nobody, and work out why an Endpoint Privilege Management rule doesn't elevate.

### Part A – Windows LAPS

1. In the Intune admin center, go to Endpoint security → Account protection → Create policy → Windows → **Local admin password solution (Windows LAPS)** and create the policy `flaneX-LAPS`, assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Backup Directory | Backup the password to Azure AD only |
   | Password Age Days | 7 |
   | Administrator Account Name | `flaneX-admin` |

2. Sync CL3. Rather than wait, start a processing cycle right away in an elevated PowerShell on CL3.

   ```powershell
   Invoke-LapsPolicyProcessing
   ```

3. In Event Viewer, open Applications and Services Logs → Microsoft → Windows → LAPS → Operational and read the last cycle from **10003** (start) to **10004** (success) or **10005** (failure). Which event explains the failure?
4. Collect the evidence you would attach to a ticket:

   ```powershell
   Get-LapsDiagnostics -OutputFolder C:\LapsDiag
   ```

5. Repair `flaneX-LAPS` by letting Windows LAPS create and manage the account itself: **Automatic Account Management Enabled** = Enabled, target = a new custom account, name `flaneX-admin`. Sync, then run `Invoke-LapsPolicyProcessing` once more.
6. In the Intune admin center, open Devices → `CL3-yourname` → **Local admin password** and check account name, last rotation and password.

### Part B – Endpoint Privilege Management

7. On CL3, copy `cmtrace.exe` from `\\flane.file.core.windows.net\labfiles` to `C:\Tools` and get its hash.

   ```powershell
   Get-FileHash -Path C:\Tools\cmtrace.exe -Algorithm SHA256
   ```

8. In the Intune admin center under Endpoint security → Endpoint Privilege Management, create these two policies and assign both to `studentXdevices`:
   - **Windows elevation settings policy** `flaneX-EPM Settings`: EPM **Enabled**, default elevation response **Deny all requests**.
   - **Windows elevation rules policy** `flaneX-EPM Rules`: a single rule for `cmtrace.exe` with the hash from step 7, elevation type **User confirmed**.
9. Sync CL3. As soon as the EPM agent is installed, check what it received:

   ```powershell
   Import-Module 'C:\Program Files\Microsoft EPM Agent\EpmTools\EpmCmdlets.dll'
   Get-Policies -PolicyType ElevationRules
   Get-ClientSettings
   Get-FileAttributes -FilePath C:\Tools\cmtrace.exe
   ```

10. Right-click `cmtrace.exe` on the **share** and choose **Run with elevated access**. Then do the same with the copy in `C:\Tools`. What's the difference?
11. Have your partner sign in to your CL4 with their account `flaneY`. Only the account that joined a device to Microsoft Entra ID becomes its local administrator, so `flaneY` is a standard user on your CL4. Copy `cmtrace.exe` to `C:\Tools` on CL4 and repeat step 10 there.
12. Under Endpoint Privilege Management → **Reports**, find your elevations. How does the elevation from your own account appear?

### Checkpoint

- [ ] LAPS: you found the failing cycle, named the event ID, and `C:\LapsDiag` holds `LapsDiagnostics_*.zip`
- [ ] LAPS: after the fix, the log shows 10004 and Intune shows the password
- [ ] EPM: `Get-Policies` lists your rule
- [ ] EPM: you can explain why neither the file on the share nor the elevation from your own account worked as planned

### Good to know

- **Existing accounts only:** Windows LAPS manages an account that already exists – a name the device doesn't have ends the cycle with event 10013. Automatic account management (Windows 11 24H2 and later) creates the account.
- **Local files only:** EPM elevates local files, not files on a network share.
- **Admins are out of scope:** EPM doesn't manage elevations of users who are already local administrators – they appear as unmanaged elevations.

**Background:** From the user's point of view, LAPS and EPM fail silently. The event log and the EpmTools cmdlets reveal which layer broke: policy not received, rule not matching, or a case EPM doesn't support.

<!-- VERIFY: exact display names of the automatic account management settings in the Intune LAPS profile -->
<!-- VERIFY: Get-FileAttributes parameter name (-FilePath) -->
<!-- VERIFY: tenant-wide LAPS or EPM policies on studentXdevices that would conflict -->
