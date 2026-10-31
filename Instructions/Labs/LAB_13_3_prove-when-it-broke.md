---
title: 'Lab 13.3 – Prove when it broke'
lab:
    title: 'Lab 13.3 – Prove when it broke'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 13.3 – Prove when it broke

**Estimated time:** 30 minutes (if time permits)

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Answer the three questions of every compliance ticket – what is the state now, since when, and who changed what – with a Graph export, the audit log and the Intune Data Warehouse in Excel.

**Starting point:** In Lab 7.1 you made CL3 noncompliant with `studentX-MinOS` and repaired it. That is your incident. The scripts are in `C:\Toolbox` from Lab 13.2, the Excel queries in `C:\Toolbox\DataWarehouse`.

### Part A – Now: snapshot with Graph

1. CL3, Windows PowerShell:

   ```powershell
   cd C:\Toolbox
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset DeviceCompliance
   ```

   Open the CSV in Excel and filter on `CL3-yourname` and `CL4-yourname`: `ComplianceState`, `InGracePeriodUntil`, `LastContact`.

### Part B – Since when: trend

2. Daily counts per compliance state for the whole tenant:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Export-IntuneReport.ps1 -Preset DeviceComplianceTrend
   ```

   Filter on `ComplianceState` = noncompliant. Do you see the day of Lab 7.1?
3. Intune admin center → Reports → Intune Data warehouse → **Data warehouse**: copy the OData feed URL, without `?api-version=...`.
4. Excel → Data → Get Data → From Other Sources → **Blank Query** → Advanced Editor: paste `DataWarehouse\ComplianceTrend.pq`, replace the value of `FeedUrl` with your URL, **Done**. Sign in with **Organizational account** as `studentX`, then **Close & Load**.
5. Insert a line chart from the table. Compare the curve with the CSV from step 2.
6. Same way with `DataWarehouse\Devices.pq`: compare `lastSyncDateTime` of CL3 and CL4 with Devices → `CL3-yourname` → **Last check-in** in the portal.

### Part C – Who changed what

7. Intune admin center → Tenant administration → **Audit logs**: filter on the last 7 days and find the changes to `studentX-MinOS` from Lab 7.1. Who changed what, and when?
8. Fill in the table: which source answers which question?

   | Question | Graph export | Data Warehouse | Audit log |
   |---|---|---|---|
   | Is CL3 compliant right now? | | | |
   | How many devices were noncompliant per day last week? | | | |
   | Which setting in which policy was changed, by whom? | | | |
   | When did CL3 last check in? | | | |

### Checkpoint

- [ ] Compliance snapshot as CSV, CL3 and CL4 found
- [ ] Compliance trend as CSV and as line chart in Excel
- [ ] Change to `studentX-MinOS` found in the audit log with time and account
- [ ] Table filled in

**Note:** The Data Warehouse is refreshed once a day – a device that was noncompliant for an hour between two snapshots may not show up in the trend. The compliance trend is tenant-wide: in the shared training tenant you see the devices of all participants. Microsoft Graph can't be a Power Query data source, which is why Excel uses the Data Warehouse OData feed.

**Why:** "It worked yesterday" is a claim. The trend shows since when, the audit log shows the change that fits the time – that is the evidence for the ticket.

<!-- VERIFY: DeviceComplianceTrend export in the demo tenant: value of ComplianceState and how many days back -->
<!-- VERIFY: Excel on CL3 (also VERIFY in Lab 13.2) -->
<!-- VERIFY: audit log entry names the policy and the changed setting for compliance policies -->
