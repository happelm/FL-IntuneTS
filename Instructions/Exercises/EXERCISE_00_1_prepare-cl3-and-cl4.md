---
redirect_from:
  - /Instructions/Labs/LAB_00_1_set-up-your-lab.html
title: 'Exercise 0.1 – Prepare CL3 and CL4'
lab:
    title: 'Exercise 0.1 – Prepare CL3 and CL4'
    module: 'Day 1 – Troubleshooting enrollment and configuration'
---

# Exercise 0.1 – Prepare CL3 and CL4

**Estimated time:** 25 minutes

**Goal:** Get CL3 and CL4 into the training tenant and your device group under names that everybody can find, and sign in with Windows Hello.

> [!IMPORTANT]
> **Online participants (Fast Lane Remote Labs) – keyboard layout:** the remote lab session converts the keyboard layout twice. On a German keyboard, pick **English (US)** when CL3 and CL4 ask for the layout during OOBE – that is the only way to type characters such as `@` and `-`. Any other layout scatters them across odd keys (not simply the US positions).
>
> **Working from a Mac, or a character still missing?** At OOBE, press **Shift+F10**, type `osk` and press Enter. The on-screen keyboard opens, and you click the characters you need.
>
> **Already past the keyboard question with the wrong layout?** At OOBE, press **Shift+F10**, paste this line and press Enter – the layout changes to English (US) immediately:
>
> ```powershell
> powershell Set-WinUserLanguageList en-US -Force
> ```
>
> **Copy and paste:** **Ctrl+Shift+Alt+C** copies, **Ctrl+Shift+Alt+V** pastes. Plain Ctrl+C / Ctrl+V don't cross between your computer and the remote lab.

1. Ask the trainer for your user `flaneX` and your number X. Your groups carry the same number: `studentXdevices` and `studentXusers`.
2. Start CL3. In OOBE, pick your region and keyboard layout and skip the second keyboard layout.

   > ⌨ **Online participants – keyboard layout question:** pick **English (US)**, even on a German keyboard. Still no `@` or `-`? **Shift+F10** → `osk` → Enter brings up the on-screen keyboard.

3. The network connects by itself. Should Windows look for updates, let it finish.
4. When OOBE asks for a device name, type `CL3-yourname` and select **Next**. The client restarts.
5. Pick **Set up for work or school** and sign in as `flaneX`, which joins the client to Microsoft Entra ID. Complete MFA.
6. The privacy settings are up to you.
7. When Windows offers Windows Hello, set up a PIN.

   > **Hold off on the enhanced session until the PIN is set up:** Hyper-V may pop up a window with a **screen resolution slider** (enhanced session). Close it for the moment and don't select **Connect** yet – Connect turns the console into an RDP connection, and the Windows Hello PIN setup fails over RDP. Once the PIN works, the enhanced session is fine (for copy and paste, for instance). Already connected? View → **Enhanced Session** (clear the checkmark), then set up the PIN again.

8. On CL4, go through steps 2–7 again with the device name `CL4-yourname`.
9. In the Entra admin center, open Groups → `studentXdevices` → Members and add `CL3-yourname` and `CL4-yourname`.
10. From here on, start the name of every object you create in the tenant with `flaneX-`.

### Checkpoint

- [ ] `dsregcmd /status` shows `AzureAdJoined : YES` on CL3 and CL4
- [ ] The Intune admin center lists both devices under Devices → Windows
- [ ] `studentXdevices` contains both devices
- [ ] Your Windows Hello PIN signs you in on CL3 and CL4

**Joined, but missing in Intune?** Then MDM auto-enrollment didn't run. Download `Autoenroll.ps1` from the [Labfiles](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles) and run it in an elevated PowerShell on that client. The script writes the Intune enrollment URLs to `HKLM\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\<tenant ID>` and triggers the enrollment with `deviceenroller.exe /c /AutoEnrollMDM`; the device enrolls as a corporate device. Give it a few minutes, then go through the checkpoint again.

### Good to know

- **Name length:** computer names are limited to 15 characters, so shorten `yourname` where needed. Your roles only reach devices that follow the lab naming pattern – keep the `CL3-` / `CL4-` prefix.

**Background:** All assignments in the coming labs target `studentXdevices` or `studentXusers`. A device outside your group receives nothing.
