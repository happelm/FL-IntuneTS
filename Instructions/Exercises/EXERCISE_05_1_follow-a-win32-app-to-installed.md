---
redirect_from:
  - /Instructions/Labs/LAB_05_1_trace-a-win32-app.html
title: 'Exercise 5.1 – Follow a Win32 app to Installed'
lab:
    title: 'Exercise 5.1 – Follow a Win32 app to Installed'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 5.1 – Follow a Win32 app to Installed

**Estimated time:** 45 minutes

**Goal:** Trace a single Win32 app from its assignment all the way to **Installed** – in the log, in the registry and in the portal.

1. Download `cmtrace.intunewin` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles). `cmtrace.exe`, `CmtraceInstall.ps1` and `CmtraceRemove.ps1` are already inside the package.
2. In the Intune admin center under Apps → Windows, add the **Windows app (Win32)** `flaneX-CMTrace` from `cmtrace.intunewin` with the settings below and assign it as **Required** to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Install command | `PowerShell.exe -ExecutionPolicy Bypass -File "CmtraceInstall.ps1"` |
   | Uninstall command | `PowerShell.exe -ExecutionPolicy Bypass -File "CmtraceRemove.ps1"` |
   | Install behavior | System |
   | Detection rule | File: `C:\Windows`, file or folder `CMTrace.exe`, file or folder exists |

3. Write down the app ID of `flaneX-CMTrace`. Open the app in the Intune admin center – the ID is the GUID at the end of the browser URL.
4. On CL3, open `AppWorkload.log` in CMTrace and highlight the app ID (Tools → Highlight; `Ctrl+F` jumps between hits). Read the highlighted lines from top to bottom and find the lifecycle stages from the slides, in this order:
   1. the app policy carrying your app ID arrives
   2. detection before the install doesn't find the app
   3. the content is downloaded, hash-checked, decrypted and unzipped into `C:\Windows\IMECache`
   4. the install command from step 2 runs and returns its exit code
   5. detection after the install finds the app
   6. the result goes back to Intune
5. **Optional:** if `AppWorkload.log` still shows nothing about your app after 3–5 minutes, restart the IME from an elevated PowerShell:

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

6. On CL3, open `regedit`, go to `HKLM\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps` and find the key with your app ID and its state.
7. In the Intune admin center, hold the install status of `flaneX-CMTrace` on CL3 against what the log tells you.

### Checkpoint

- [ ] `AppWorkload.log` shows download, install and detection of `flaneX-CMTrace`
- [ ] You found the app key and its state message in the registry
- [ ] The portal reports **Installed** for CL3

### Good to know

- **Where the keys sit:** under `Win32Apps`, apps assigned to the device are stored below the all-zeros GUID, apps assigned to a user below that user's Entra object ID.

**Background:** **Installed** is decided by the detection rule, not by the exit code alone. If portal and log disagree, trust the log.
