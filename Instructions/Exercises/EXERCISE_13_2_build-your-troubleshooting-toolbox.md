---
redirect_from:
  - /Instructions/Labs/LAB_13_2_build-your-troubleshooting-toolbox.html
title: 'Exercise 13.2 – Build your troubleshooting toolbox'
lab:
    title: 'Exercise 13.2 – Build your troubleshooting toolbox'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 13.2 – Build your troubleshooting toolbox

**Estimated time:** 90 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Answer the opening questions of a support case with read-only scripts – and hold each answer against the portal and against Device query.

**Starting point:** The scripts live in the `Toolbox` folder of the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles). They only read: every call is a Graph GET, and the report export is a POST that creates an export job. Exercise 13.1 showed the individual calls – here they turn into tools.

### Part A – Prepare CL3

1. On CL3, copy the `Toolbox` folder to `C:\Toolbox`. Open Windows PowerShell and, if it is missing, install the Graph module for your account:

   ```powershell
   Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
   ```

2. Read the first 100 lines of `Get-IntunePolicyAssignmentsByGroup.ps1`: which Graph scopes does it request, and why only `Read`?

### Part B – What hits this device?

3. Run the device view for CL3. Sign in as `flaneX` when prompted and confirm the tenant:

   ```powershell
   cd C:\Toolbox
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-IntunePolicyAssignmentsByGroup.ps1 -DeviceName CL3-yourname -ExportCsv
   ```

4. Compare the result with the portal under Devices → `CL3-yourname` → Device configuration. Which objects does the script list that the device view leaves out – and why?
5. Run the group view for your device group:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-IntunePolicyAssignmentsByGroup.ps1 -GroupName studentXdevices -ExportCsv
   ```

6. Then look for objects that reach nobody, and filter the CSV on `flaneX-`:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Find-UnassignedIntuneObjects.ps1 -ExportCsv
   ```

### Part C – Results of all devices in one file

7. List the report presets:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -ListPresets
   ```

8. Export the results of your remediation `flaneX-Reg` from Exercise 6.1 (take the remediation ID from the browser address bar):

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset RemediationResults -PolicyId <remediation ID>
   ```

9. Export the install status of your app `flaneX-CMTrace` from Exercise 5.1:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset AppInstallStatusByDevice -ApplicationId <app ID>
   ```

10. Open both CSV files in Excel and find the detection output of CL3 before and after the remediation.

### Part D – Live from the device

11. In the Intune admin center, open Devices → `CL3-yourname` → **Device query** and check the state `flaneX-Reg` enforces, plus the IME service.

    ```text
    WindowsRegistry('HKEY_LOCAL_MACHINE\\SOFTWARE\\flaneX\\Lab')
    ```

    ```text
    WindowsService | where ServiceName == 'IntuneManagementExtension'
    ```

12. Complete the table: which tool answers which question?

    | Question | Portal | Script | Device query |
    |---|---|---|---|
    | Which objects target CL3, including All devices and nested groups? | | | |
    | What did the remediation report on every device? | | | |
    | Is the registry key there right now? | | | |

### Checkpoint

- [ ] You have device view and group view as CSV and can explain one difference to the portal
- [ ] You found at least one of your objects as unassigned or exclude-only – or none, and know why
- [ ] Remediation results and app install status are saved as CSV, and CL3 appears in both
- [ ] Device query returned the registry key and the IME service
- [ ] The table is complete

### Good to know

- **Device view vs. group view:** the device view resolves every group CL3 belongs to, transitively, plus All devices. The group view only follows group nesting – it doesn't show what the group's members receive through their other groups.
- **Device query:** it reads the device live, one device at a time.

**Background:** Every support case opens with the same questions. The portal answers them page by page; a script answers them in one run and leaves a CSV for the ticket.

<!-- VERIFY: admin consent for the delegated scopes of the Toolbox scripts (Microsoft Graph Command Line Tools) in the training tenant -->
<!-- VERIFY: Device query WindowsRegistry escaping of the key path -->
<!-- VERIFY: Excel on CL3 – otherwise open the CSV in Notepad -->
