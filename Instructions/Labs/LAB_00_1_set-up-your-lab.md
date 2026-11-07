---
title: 'Lab 0.1 – Set up your lab'
lab:
    title: 'Lab 0.1 – Set up your lab'
    module: 'Day 1 – Method, enroll, configure'
---

# Lab 0.1 – Set up your lab

**Estimated time:** 20 minutes

**Goal:** Bring CL3 and CL4 into the training tenant and into your device group, named so that everybody can find them, and sign in with Windows Hello.

> [!IMPORTANT]
> **Online participants (Fast Lane Remote Labs) – keyboard layout:** the remote lab session translates the keyboard layout twice. If you sit at a German keyboard, choose **English (US)** when CL3 and CL4 ask for the keyboard layout during OOBE – only then can you type characters like `@` and `-`. With any other layout they end up on unusual keys (not simply the US positions).
>
> **On a Mac, or if a character still doesn't work:** press **Shift+F10** at OOBE, type `osk` and press Enter – the on-screen keyboard opens and you click the characters you need.
>
> **Copy and paste:** copy with **Ctrl+Shift+Alt+C** and paste with **Ctrl+Shift+Alt+V**. The normal Ctrl+C / Ctrl+V don't work between your computer and the remote lab.

1. Look up your user `studentX` and your number X in `course.txt` from the trainer.
2. CL3 and CL4 start at OOBE. When OOBE asks for the device name, enter `CL3-yourname` and `CL4-yourname`. Choose any privacy settings.

   > ⌨ **Online participants – keyboard layout question:** choose **English (US)**, even if you sit at a German keyboard. If `@` or `-` still don't work: **Shift+F10** → `osk` → Enter opens the on-screen keyboard.

3. Sign in with `studentX` as work or school account – this joins the client to Microsoft Entra ID. Complete MFA and set up Windows Hello with a PIN when Windows asks for it.
4. Entra admin center → Groups → `studentXdevices` → Members: add `CL3-yourname` and `CL4-yourname`.
5. From now on, every object you create in the tenant starts with `studentX-`.

### Checkpoint

- [ ] `dsregcmd /status` on CL3 and CL4: `AzureAdJoined : YES`
- [ ] Both devices listed in Intune admin center → Devices → Windows
- [ ] Both devices are members of `studentXdevices`
- [ ] Sign-in with your Windows Hello PIN works on CL3 and CL4

**If a device is joined but not in Intune:** MDM auto-enrollment did not run. Download `Autoenroll.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles) and run it in an elevated PowerShell on that client. The script writes the Intune enrollment URLs to `HKLM\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\<tenant ID>` and starts the enrollment with `deviceenroller.exe /c /AutoEnrollMDM` – the device enrolls as corporate device. Check the checkpoint again after a few minutes.

**Note:** A computer name has at most 15 characters – shorten `yourname` if needed. Your roles only reach devices whose name matches the lab naming pattern, so keep the `CL3-` / `CL4-` prefix.

**Why:** Every assignment in the following labs targets `studentXdevices` or `studentXusers`. A device that is not in your group gets nothing.
