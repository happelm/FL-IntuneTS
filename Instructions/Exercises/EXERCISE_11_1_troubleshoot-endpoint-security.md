---
redirect_from:
  - /Instructions/Labs/LAB_11_1_troubleshoot-endpoint-security.html
title: 'Exercise 11.1 – Troubleshoot endpoint security'
lab:
    title: 'Exercise 11.1 – Troubleshoot endpoint security'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 11.1 – Troubleshoot endpoint security

**Estimated time:** 75 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Trace three endpoint security policies from the portal to the client – and work out why one of them can't work on CL3.

**Starting point:** CL3 is onboarded to Microsoft Defender for Endpoint automatically through `studentXdevices`. All participants share the same tenant, so assign your policies to `studentXdevices` only.

### Part A – Policies

1. In the Intune admin center under Endpoint security, create these policies for platform **Windows** and assign each to `studentXdevices`:

   | Policy | Type | Settings |
   |---|---|---|
   | `flaneX-ASR Audit` | Attack surface reduction → Attack Surface Reduction Rules | **Block process creations originating from PSExec and WMI commands** = **Audit** |
   | `flaneX-BitLocker` | Disk encryption → BitLocker | Require device encryption, silent encryption of the OS drive, recovery key backup to Microsoft Entra ID |
   | `flaneX-AV` | Antivirus → Microsoft Defender Antivirus | Exclusion for the folder `C:\Source` |

2. Sync CL3.

### Part B – Defender for Endpoint and antivirus

3. On CL3, check in PowerShell whether the sensor is onboarded and running.

   ```powershell
   Get-Service -Name Sense
   Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status' -Name OnboardingState
   ```

4. Next, check the antivirus state and your exclusion:

   ```powershell
   Get-MpComputerStatus | Select-Object AMRunningMode, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated
   Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
   ```

5. In the Intune admin center, open Endpoint security → Antivirus → `flaneX-AV` → device status. Then go to Devices → `CL3-yourname` → Device configuration: does any policy show **Conflict**? Open it and note which setting collides with which policy.

### Part C – ASR rule in audit mode

6. On CL3, list the ASR rules with their mode in PowerShell (`2` = Audit, `1` = Block).

   ```powershell
   $p = Get-MpPreference
   0..($p.AttackSurfaceReductionRules_Ids.Count - 1) | ForEach-Object {
       [pscustomobject]@{ Id = $p.AttackSurfaceReductionRules_Ids[$_]; Action = $p.AttackSurfaceReductionRules_Actions[$_] }
   }
   ```

7. Now trigger the rule by starting a process through WMI:

   ```powershell
   Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'notepad.exe' }
   ```

8. In Event Viewer, go to Applications and Services Logs → Microsoft → Windows → Windows Defender → Operational and filter on event ID **1122**. Notepad started regardless – why?

### Part D – BitLocker

9. On CL3, run in an elevated PowerShell:

   ```powershell
   manage-bde -status C:
   Get-Tpm
   ```

10. Work out why BitLocker did or didn't start by following the chain in this order:
    - Event Viewer → Microsoft → Windows → DeviceManagement-Enterprise-Diagnostics-Provider → Admin: errors for `./Device/Vendor/MSFT/BitLocker/…`
    - Event Viewer → Microsoft → Windows → BitLocker-API → Management: events 853, 854, 851
    - Task Scheduler → Microsoft → Windows → BitLocker → **BitLocker MDM policy Refresh**: last run result
11. In the Intune admin center, open Devices → `CL3-yourname` → **Device query** and check the same from the portal side.

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

- [ ] The `Sense` service is running and `OnboardingState` = `1`
- [ ] `ExclusionPath` contains `C:\Source` – or you can name the conflict that explains why not
- [ ] The ASR rule is in mode `2`, and event 1122 records your WMI process start
- [ ] For BitLocker, you know the state of `C:` and the reason, with the event ID as evidence
- [ ] Device query gives the same answer as the client

### Good to know

- **Audit mode:** it logs what the rule would block, which is why Notepad still starts.
- **Silent encryption blockers:** a missing or unready TPM stops silent encryption with event 853 in BitLocker-API → Management. A startup PIN or startup key set to *Required* breaks silent encryption as well.

**Background:** Endpoint security policies, security baselines and configuration profiles can all set the same setting. The portal reports a conflict, the client shows which value won. Start on the client, then return to the portal.

<!-- VERIFY: WMI Win32_Process Create triggers 1122 for rule d1e49aac-8f56-4280-b9ba-993a6d77406c -->
<!-- VERIFY: Lab-Administrator for Students creates AV/BitLocker policies (SecurityBaselines permission) -->
<!-- VERIFY: WindowsEvent log name syntax with a slash in Device query -->
