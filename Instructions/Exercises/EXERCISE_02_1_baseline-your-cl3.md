---
redirect_from:
  - /Instructions/Labs/LAB_02_1_collect-and-read-intune-logs.html
title: 'Exercise 2.1 – Baseline your CL3'
lab:
    title: 'Exercise 2.1 – Baseline your CL3'
    module: 'Day 1 – Troubleshooting enrollment and configuration'
---

# Exercise 2.1 – Baseline your CL3

**Estimated time:** 30 minutes

**Goal:** Record a known-good baseline of your own CL3. Every later module measures against it.

1. In the Intune admin center, open Devices → All devices → `CL3-yourname` and select **Collect diagnostics**, then sync CL3. The package takes about 15 minutes to arrive – carry on with the next steps in the meantime.
2. On CL3, go to Settings → Accounts → Access work or school and select **Export your management log files**. Open the report in `C:\Users\Public\Documents\MDMDiagnostics`.
3. Still on CL3, open an elevated command prompt, build the diagnostics package from the command line and compare it with the report from step 2.

   ```cmd
   mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning;Autopilot" -zip "C:\Users\Public\Documents\MDMDiagReport.zip"
   ```

4. Next, connect the lab share (an Azure file share) on CL3 and copy `cmtrace.exe` to the desktop. Entra-joined clients don't come with mapped network drives, so connect the share first. It is reachable only from CL3 and CL4, signed in as `flaneX`.

   ```cmd
   net use \\flane.file.core.windows.net\labfiles
   ```

   Then open `IntuneManagementExtension.log` from `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` in CMTrace.
5. Back in the Intune admin center, go to Devices → All devices → `CL3-yourname` → Monitor → Device diagnostics, download the package from step 1 and locate the same information inside it.

### Checkpoint

- [ ] The MDM report shows your enrollment and the managed policies
- [ ] You downloaded and opened the diagnostics package
- [ ] For each of the five layers, you can name the log (see the [log map](../Appendix.html#log-map))

### Good to know

- **What's in the zip:** the output of `mdmdiagnosticstool.exe` holds `MDMDiagHtmlReport.html`, `MDMDiagReport.xml`, a registry dump and the DeviceManagement-Enterprise-Diagnostics-Provider Admin event log. `HKLM\SOFTWARE\Microsoft\MdmDiagnostics\Area` lists the available areas.

**Background:** Nobody breaks devices on purpose in this course. Instead, you learn what a healthy CL3 logs, so that anything unusual jumps out later. Hold on to this baseline – Lesson 3 compares against it.
