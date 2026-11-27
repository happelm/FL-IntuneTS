---
redirect_from:
  - /Instructions/Labs/LAB_00_1_set-up-your-lab.html
title: 'Exercise 0.1 – Prepare CL3 and CL4'
lab:
    title: 'Exercise 0.1 – Prepare CL3 and CL4'
    module: 'Day 1 – Method, enroll, configure'
---

# Exercise 0.1 – Prepare CL3 and CL4

**Estimated time:** 25 minutes

**Goal:** Bring CL3 and CL4 into the training tenant and into your device group, named so that everybody can find them, and sign in with Windows Hello.

> [!IMPORTANT]
> **Online participants (Fast Lane Remote Labs) – keyboard layout:** the remote lab session translates the keyboard layout twice. If you sit at a German keyboard, choose **English (US)** when CL3 and CL4 ask for the keyboard layout during OOBE – only then can you type characters like `@` and `-`. With any other layout they end up on unusual keys (not simply the US positions).
>
> **On a Mac, or if a character still doesn't work:** press **Shift+F10** at OOBE, type `osk` and press Enter – the on-screen keyboard opens and you click the characters you need.
>
> **Already past the keyboard question with the wrong layout?** Press **Shift+F10** at OOBE, paste this line and press Enter. The layout switches to English (US) right away:
>
> ```powershell
> powershell Set-WinUserLanguageList en-US -Force
> ```
>
> **Copy and paste:** copy with **Ctrl+Shift+Alt+C** and paste with **Ctrl+Shift+Alt+V**. The normal Ctrl+C / Ctrl+V don't work between your computer and the remote lab.

1. Get your user `flaneX` and your number X from the trainer. Your groups use the same number: `studentXdevices` and `studentXusers`.
2. Start CL3. OOBE begins: select your region and keyboard layout, skip the second keyboard layout.

   > ⌨ **Online participants – keyboard layout question:** choose **English (US)**, even if you sit at a German keyboard. If `@` or `-` still don't work: **Shift+F10** → `osk` → Enter opens the on-screen keyboard.

3. The network connects automatically. If Windows checks for updates, wait until it is done.
4. When OOBE asks for the device name, enter `CL3-yourname` and select **Next**. The client restarts.
5. Select **Set up for work or school** and sign in with `flaneX` – this joins the client to Microsoft Entra ID. Complete MFA.
6. Choose any privacy settings.
7. Set up Windows Hello with a PIN when Windows asks for it.

   > **Wait with the enhanced session until your PIN is set up:** Hyper-V may show a window with a **screen resolution slider** (enhanced session). Close it for now and don't select **Connect** yet – Connect switches the console to an RDP connection, and the Windows Hello PIN setup fails over RDP. Once the PIN works, you can use the enhanced session (for example for copy and paste). If you already connected: View → **Enhanced Session** (clear the checkmark), then set up the PIN again.

8. Repeat steps 2–7 on CL4 with the device name `CL4-yourname`.
9. Entra admin center → Groups → `studentXdevices` → Members: add `CL3-yourname` and `CL4-yourname`.
10. From now on, every object you create in the tenant starts with `flaneX-`.

### Checkpoint

- [ ] `dsregcmd /status` on CL3 and CL4: `AzureAdJoined : YES`
- [ ] Both devices listed in Intune admin center → Devices → Windows
- [ ] Both devices are members of `studentXdevices`
- [ ] Sign-in with your Windows Hello PIN works on CL3 and CL4

**If a device is joined but not in Intune:** MDM auto-enrollment did not run. Download `Autoenroll.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles) and run it in an elevated PowerShell on that client. The script writes the Intune enrollment URLs to `HKLM\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\<tenant ID>` and starts the enrollment with `deviceenroller.exe /c /AutoEnrollMDM` – the device enrolls as corporate device. Check the checkpoint again after a few minutes.

**Note:** A computer name has at most 15 characters – shorten `yourname` if needed. Your roles only reach devices whose name matches the lab naming pattern, so keep the `CL3-` / `CL4-` prefix.

**Why:** Every assignment in the following labs targets `studentXdevices` or `studentXusers`. A device that is not in your group gets nothing.

