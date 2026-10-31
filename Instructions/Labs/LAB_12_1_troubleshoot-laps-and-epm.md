---
title: 'Lab 12.1 – Troubleshoot LAPS and EPM'
lab:
    title: 'Lab 12.1 – Troubleshoot LAPS and EPM'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 12.1 – Troubleshoot LAPS and EPM

**Estimated time:** 60 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Read a Windows LAPS processing cycle in the event log, fix a policy that manages nobody, and find out why an Endpoint Privilege Management rule does not elevate.

### Part A – Windows LAPS

1. Intune admin center → Endpoint security → Account protection → Create policy → Windows → **Local admin password solution (Windows LAPS)**: policy `studentX-LAPS`, assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Backup Directory | Backup the password to Azure AD only |
   | Password Age Days | 7 |
   | Administrator Account Name | `studentX-admin` |

2. Sync CL3. CL3, elevated PowerShell: start a processing cycle now instead of waiting.

   ```powershell
   Invoke-LapsPolicyProcessing
   ```

3. Event Viewer → Applications and Services Logs → Microsoft → Windows → LAPS → Operational. Read the last cycle from **10003** (start) to **10004** (success) or **10005** (failure). Which event explains the failure?
4. Collect the evidence for a ticket:

   ```powershell
   Get-LapsDiagnostics -OutputFolder C:\LapsDiag
   ```

5. Fix `studentX-LAPS`: let Windows LAPS create and manage the account itself – **Automatic Account Management Enabled** = Enabled, target = a new custom account, name `studentX-admin`. Sync and run `Invoke-LapsPolicyProcessing` again.
6. Intune admin center → Devices → `CL3-yourname` → **Local admin password**: account name, last rotation, password.

### Part B – Endpoint Privilege Management

7. CL3: copy `cmtrace.exe` from `\\flane.file.core.windows.net\labfiles` to `C:\Tools` and get its hash.

   ```powershell
   Get-FileHash -Path C:\Tools\cmtrace.exe -Algorithm SHA256
   ```

8. Intune admin center → Endpoint security → Endpoint Privilege Management, assigned to `studentXdevices`:
   - **Windows elevation settings policy** `studentX-EPM Settings`: EPM **Enabled**, default elevation response **Deny all requests**.
   - **Windows elevation rules policy** `studentX-EPM Rules`: one rule for `cmtrace.exe` with the hash from step 7, elevation type **User confirmed**.
9. Sync CL3. Once the EPM agent is installed, check what it received:

   ```powershell
   Import-Module 'C:\Program Files\Microsoft EPM Agent\EpmTools\EpmCmdlets.dll'
   Get-Policies -PolicyType ElevationRules
   Get-ClientSettings
   Get-FileAttributes -FilePath C:\Tools\cmtrace.exe
   ```

10. Right-click `cmtrace.exe` on the **share** → **Run with elevated access**. Then the same on the copy in `C:\Tools`. What is the difference?
11. Sign in to CL4 with your partner's account `studentY` – a standard user on your device. Copy `cmtrace.exe` to `C:\Tools` on CL4 and repeat step 10 there.
12. Endpoint Privilege Management → **Reports**: find your elevations. How is the elevation from your own account listed?

### Checkpoint

- [ ] LAPS: failing cycle found, event ID named, `LapsDiagnostics_*.zip` in `C:\LapsDiag`
- [ ] LAPS: after the fix 10004 in the log, password visible in Intune
- [ ] EPM: `Get-Policies` lists your rule
- [ ] EPM: you can explain why the file on the share and the elevation from your own account did not work as planned

**Note:** Windows LAPS manages an existing account only – a name that does not exist on the device ends the cycle with event 10013. Automatic account management (Windows 11 24H2 and later) creates the account. EPM elevates local files only, not files on a network share. EPM doesn't manage elevations of users who are already local administrators – they show up as unmanaged elevations.

**Why:** LAPS and EPM fail silently from the user's point of view. The event log and the EpmTools cmdlets tell you which layer broke: policy not received, rule not matching, or a case EPM doesn't support.

<!-- VERIFY: Entra LAPS enabled in the tenant (Entra admin center → Devices → Device settings) -->
<!-- VERIFY: studentX can read the LAPS password (Cloud Device Administrator in the AU scope) -->
<!-- VERIFY: exact display names of the automatic account management settings in the Intune LAPS profile -->
<!-- VERIFY: Get-FileAttributes parameter name (-FilePath) -->
<!-- VERIFY: studentX is local admin on CL3/CL4 (Entra join user) – then step 11 needs the partner account as standard user -->
<!-- VERIFY: tenant-wide LAPS or EPM policies on studentXdevices that would conflict -->
