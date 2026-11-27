---
redirect_from:
  - /Instructions/Labs/LAB_13_3_prove-when-it-broke.html
title: 'Exercise 13.3 – Prove when it broke'
lab:
    title: 'Exercise 13.3 – Prove when it broke'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 13.3 – Prove when it broke

**Estimated time:** 30 minutes (if time permits)

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Answer the three questions behind every compliance ticket – what is the state now, since when, and who changed what – using a Graph export, the audit log and the Intune Data Warehouse in Excel.

**Starting point:** Exercise 7.1 made CL3 noncompliant with `flaneX-MinOS` and repaired it – that is your incident. The scripts sit in `C:\Toolbox` from Exercise 13.2, the Excel queries in `C:\Toolbox\DataWarehouse`.

### Part A – Now: snapshot with Graph

1. On CL3, run in Windows PowerShell:

   ```powershell
   cd C:\Toolbox
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset DeviceCompliance
   ```

   Open the CSV in Excel, filter on `CL3-yourname` and `CL4-yourname` and read `ComplianceState`, `InGracePeriodUntil` and `LastContact`.

### Part B – Since when: trend

2. Export the daily counts per compliance state for the whole tenant:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset DeviceComplianceTrend
   ```

   Filter on `ComplianceState` = noncompliant. Can you spot the day of Exercise 7.1?
3. In the Intune admin center, go to Reports → Intune Data warehouse → **Data warehouse** and copy the OData feed URL, leaving out `?api-version=...`.
4. In Excel, choose Data → Get Data → From Other Sources → **Blank Query** and open the Advanced Editor. Paste `DataWarehouse\ComplianceTrend.pq`, replace the value of `FeedUrl` with your URL and select **Done**. Sign in with **Organizational account** as `flaneX`, then select **Close & Load**.
5. Insert a line chart from the table and compare the curve with the CSV from step 2.
6. Repeat with `DataWarehouse\Devices.pq` and compare `lastSyncDateTime` of CL3 and CL4 with Devices → `CL3-yourname` → **Last check-in** in the portal.

### Part C – Who changed what

7. In the Intune admin center under Tenant administration → **Audit logs**, filter on the last 7 days and find the changes to `flaneX-MinOS` from Exercise 7.1. Who changed what, and when?
8. Complete the table: which source answers which question?

   | Question | Graph export | Data Warehouse | Audit log |
   |---|---|---|---|
   | Is CL3 compliant right now? | | | |
   | How many devices were noncompliant per day last week? | | | |
   | Which setting in which policy was changed, by whom? | | | |
   | When did CL3 last check in? | | | |

### Checkpoint

- [ ] The compliance snapshot is saved as CSV and contains CL3 and CL4
- [ ] The compliance trend exists as CSV and as a line chart in Excel
- [ ] The audit log shows the change to `flaneX-MinOS` with time and account
- [ ] The table is complete

### Good to know

- **Daily refresh:** the Data Warehouse refreshes once a day, so a device that was noncompliant for an hour between two snapshots may be missing from the trend.
- **Tenant-wide trend:** in the shared training tenant, the compliance trend includes the devices of all participants.
- **Why the Data Warehouse in Excel:** Microsoft Graph can't serve as a Power Query data source, so Excel uses the Data Warehouse OData feed.

**Background:** "It worked yesterday" is only a claim. The trend shows since when, and the audit log shows the change that matches the time – together they are the evidence for the ticket.

<!-- VERIFY: DeviceComplianceTrend export in the demo tenant: value of ComplianceState and how many days back -->
<!-- VERIFY: Excel on CL3 (also VERIFY in Exercise 13.2) -->
<!-- VERIFY: audit log entry names the policy and the changed setting for compliance policies -->
