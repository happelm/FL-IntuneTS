---
title: 'Lab 13.2 – Build your troubleshooting toolbox'
lab:
    title: 'Lab 13.2 – Build your troubleshooting toolbox'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 13.2 – Build your troubleshooting toolbox

**Estimated time:** 90 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Answer the first questions of a support case with read-only scripts – and compare each answer with the portal and with Device query.

**Starting point:** The scripts are in the folder `Toolbox` of the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles). They only read: every call is a Graph GET, the report export a POST that creates an export job. Lab 13.1 showed the single calls – here they become tools.

### Part A – Prepare CL3

1. CL3: copy the folder `Toolbox` to `C:\Toolbox`. Open Windows PowerShell and install the Graph module for your account if it is missing:

   ```powershell
   Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
   ```

2. Read the first 100 lines of `Get-IntunePolicyAssignmentsByGroup.ps1`: which Graph scopes does it ask for, and why only `Read`?

### Part B – What hits this device?

3. Device view for CL3 – sign in with `studentX` when asked and confirm the tenant:

   ```powershell
   cd C:\Toolbox
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-IntunePolicyAssignmentsByGroup.ps1 -DeviceName CL3-yourname -ExportCsv
   ```

4. Compare with the portal: Devices → `CL3-yourname` → Device configuration. Which objects does the script list that the device view does not show – and why?
5. Group view for your device group:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-IntunePolicyAssignmentsByGroup.ps1 -GroupName studentXdevices -ExportCsv
   ```

6. Objects that reach nobody – filter the CSV on `studentX-`:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Find-UnassignedIntuneObjects.ps1 -ExportCsv
   ```

### Part C – Results of all devices in one file

7. List the report presets:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -ListPresets
   ```

8. Export the results of your remediation `studentX-Reg` from Lab 6.1 (remediation ID from the browser address bar):

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset RemediationResults -PolicyId <remediation ID>
   ```

9. Export the install status of your app `studentX-CMTrace` from Lab 5.1:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset AppInstallStatusByDevice -ApplicationId <app ID>
   ```

10. Open both CSV files in Excel. Find the detection output of CL3 before and after the remediation.

### Part D – Live from the device

11. Intune admin center → Devices → `CL3-yourname` → **Device query**: check the state that `studentX-Reg` enforces and the IME service.

    ```text
    WindowsRegistry('HKEY_LOCAL_MACHINE\\SOFTWARE\\studentX\\Lab')
    ```

    ```text
    WindowsService | where ServiceName == 'IntuneManagementExtension'
    ```

12. Fill in the table: which tool answers which question?

    | Question | Portal | Script | Device query |
    |---|---|---|---|
    | Which objects target CL3, including All devices and nested groups? | | | |
    | What did the remediation report on every device? | | | |
    | Is the registry key there right now? | | | |

### Checkpoint

- [ ] Device view and group view as CSV; one difference to the portal explained
- [ ] At least one of your objects found as unassigned or exclude-only – or none, with the reason
- [ ] Remediation results and app install status as CSV, CL3 found in both
- [ ] Registry key and IME service read with Device query
- [ ] Table filled in

**Note:** The device view resolves every group CL3 is a member of, transitively, plus All devices. The group view only follows group nesting – it doesn't show what the group's members get through their other groups. Device query reads the device live and works for one device at a time.

**Why:** A support case starts with the same questions every time. The portal answers them page by page, a script answers them in one run and leaves a CSV for the ticket.

<!-- VERIFY: admin consent for the delegated scopes of the Toolbox scripts (Microsoft Graph Command Line Tools) in the training tenant -->
<!-- VERIFY: Device query WindowsRegistry escaping of the key path -->
<!-- VERIFY: Excel on CL3 – otherwise open the CSV in Notepad -->
