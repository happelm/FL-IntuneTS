# Trainer notes – MDM wins over GP demo (CL1)

The trainer pod shows a Group Policy / Intune conflict on CL1 in `training.flane`: the same SmartScreen setting arrives from GPO-01 and from Intune, and **MDM Wins Over GP** decides. The registry and the event log show the result.

**Prerequisites:** CL1 is hybrid joined and co-managed with the Device Configuration workload on Intune (see [Hybrid join and Microsoft Entra Kerberos](hybrid-join-entra-kerberos.md), sections 5 and 6). GPO-01 exists in the pod (Labprep) and its link is disabled by default.

## 1. Enable the GPO-01 link

On DC1 or SRV1, open **Group Policy Management**, go to `OU=Workstations` under `OU=Cloud`, and enable the link of **GPO-01 WS - Edge & Defender Baseline** (right-click the link > **Link Enabled**). Or in PowerShell:

```powershell
Set-GPLink -Name 'GPO-01 WS - Edge & Defender Baseline' -Target 'OU=Workstations,OU=Cloud,DC=training,DC=flane' -LinkEnabled Yes
```

On CL1, run `gpupdate /force` and `gpresult /r`: GPO-01 is listed under applied Group Policy objects. Read `HKLM\SOFTWARE\Policies\Microsoft\Windows\System`: `EnableSmartScreen = 1` and `ShellSmartScreenLevel = Block` come from GPO-01.

## 2. Create the conflicting Intune policy

Settings catalog policy for Windows, assigned to a device group that contains CL1:

| Setting | Value |
|---|---|
| SmartScreen → Enable Smart Screen In Shell | Enabled |
| SmartScreen → Prevent Override For Files In Shell | Disabled (the opposite of GPO-01) |
| Control Policy Conflict → MDM Wins Over GP | Enabled |

## 3. Show the result on CL1

1. Run an MDM sync on CL1 (**Settings** > **Accounts** > **Access work or school** > **Info** > **Sync**).
2. Read `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` again: `ShellSmartScreenLevel` is gone.
3. Read the Intune side: `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\SmartScreen` (`EnableSmartScreenInShell`, `PreventOverrideForFilesInShell`).
4. Open **Event Viewer** > **Applications and Services Logs** > **Microsoft** > **Windows** > **DeviceManagement-Enterprise-Diagnostics-Provider** > **Admin** and show the MDM wins over GP events for `ShellSmartScreenLevel` (operation Delete).
5. Run `gpupdate /force` and read the Policies key again: the value stays away. The event log shows a new event for `ShellSmartScreenLevel`, this time with operation Set – Group Policy tried to write the value and was blocked.

MDM Wins Over GP only covers settings of the Policy CSP. The clean solution is to remove the setting from the GPO once Intune delivers it.

## 4. Reset after the demo

1. Disable the GPO-01 link again:

   ```powershell
   Set-GPLink -Name 'GPO-01 WS - Edge & Defender Baseline' -Target 'OU=Workstations,OU=Cloud,DC=training,DC=flane' -LinkEnabled No
   ```

2. Delete the Intune policy from section 2.
3. On CL1, run an MDM sync and `gpupdate /force`.
