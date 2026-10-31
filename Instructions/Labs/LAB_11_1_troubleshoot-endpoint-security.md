---
title: 'Lab 11.1 – Troubleshoot endpoint security'
lab:
    title: 'Lab 11.1 – Troubleshoot endpoint security'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 11.1 – Troubleshoot endpoint security

**Estimated time:** 75 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Follow three endpoint security policies from the portal to the client – and find out why one of them can't work on CL3.

**Starting point:** CL3 is onboarded to Microsoft Defender for Endpoint automatically through `studentXdevices`. Every participant works in the same tenant: assign your policies to `studentXdevices` only.

### Part A – Policies

1. Intune admin center → Endpoint security, platform **Windows**, assigned to `studentXdevices`:

   | Policy | Type | Settings |
   |---|---|---|
   | `studentX-ASR Audit` | Attack surface reduction → Attack Surface Reduction Rules | **Block process creations originating from PSExec and WMI commands** = **Audit** |
   | `studentX-BitLocker` | Disk encryption → BitLocker | Require device encryption, silent encryption of the OS drive, recovery key backup to Microsoft Entra ID |
   | `studentX-AV` | Antivirus → Microsoft Defender Antivirus | Exclusion for the folder `C:\Source` |

2. Sync CL3.

### Part B – Defender for Endpoint and antivirus

3. CL3, PowerShell: is the sensor onboarded and running?

   ```powershell
   Get-Service -Name Sense
   Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -Name OnboardingState
   ```

4. Antivirus state and your exclusion:

   ```powershell
   Get-MpComputerStatus | Select-Object AMRunningMode, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated
   Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
   ```

5. Intune admin center → Endpoint security → Antivirus → `studentX-AV` → device status. Then Devices → `CL3-yourname` → Device configuration: is any policy in **Conflict**? Open it and note which setting collides with which policy.

### Part C – ASR rule in audit mode

6. CL3, PowerShell: list the ASR rules and their mode (`2` = Audit, `1` = Block).

   ```powershell
   $p = Get-MpPreference
   0..($p.AttackSurfaceReductionRules_Ids.Count - 1) | ForEach-Object {
       [pscustomobject]@{ Id = $p.AttackSurfaceReductionRules_Ids[$_]; Action = $p.AttackSurfaceReductionRules_Actions[$_] }
   }
   ```

7. Trigger the rule – start a process through WMI:

   ```powershell
   Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'notepad.exe' }
   ```

8. Event Viewer → Applications and Services Logs → Microsoft → Windows → Windows Defender → Operational: filter on event ID **1122**. Notepad started anyway – why?

### Part D – BitLocker

9. CL3, elevated PowerShell:

   ```powershell
   manage-bde -status C:
   Get-Tpm
   ```

10. Find out why BitLocker did or did not start. Follow the chain in this order:
    - Event Viewer → Microsoft → Windows → DeviceManagement-Enterprise-Diagnostics-Provider → Admin: errors for `./Device/Vendor/MSFT/BitLocker/…`
    - Event Viewer → Microsoft → Windows → BitLocker-API → Management: events 853, 854, 851
    - Task Scheduler → Microsoft → Windows → BitLocker → **BitLocker MDM policy Refresh**: last run result
11. Intune admin center → Devices → `CL3-yourname` → **Device query**: check the same from the portal.

    ```text
    TPM
    ```

    ```text
    EncryptableVolume
    ```

    ```text
    WindowsEvent('Microsoft-Windows-BitLocker/BitLocker Management', 1d) | take 20
    ```

### Checkpoint

- [ ] `Sense` service running, `OnboardingState` = `1`
- [ ] `C:\Source` in `ExclusionPath` – or a conflict named that explains why not
- [ ] ASR rule in mode `2`, event 1122 for your WMI process start
- [ ] BitLocker: state of `C:` and the reason, with the event ID as evidence
- [ ] Same answer from Device query as from the client

**Note:** Audit mode logs what the rule would block – that is why Notepad starts. A missing or unready TPM stops silent encryption with event 853 in BitLocker-API → Management. Startup PIN or startup key set to *Required* also breaks silent encryption.

**Why:** Endpoint security policies, security baselines and configuration profiles can set the same setting. The portal shows a conflict, the client shows what won. Start with the client, then go back to the portal.

<!-- VERIFY: WMI Win32_Process Create triggers 1122 for rule d1e49aac-8f56-4280-b9ba-993a6d77406c -->
<!-- VERIFY: vTPM on CL3 in the nested VMware pod; without it BitLocker fails with 853 (good teaching case) -->
<!-- VERIFY: Lab-Administrator for Students creates AV/BitLocker policies (SecurityBaselines permission) -->
<!-- VERIFY: WindowsEvent log name syntax with a slash in Device query -->
