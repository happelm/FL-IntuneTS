---
redirect_from:
  - /Instructions/Labs/LAB_04_1_trace-a-policy-to-the-registry.html
title: 'Exercise 4.1 – Follow a policy into the registry'
lab:
    title: 'Exercise 4.1 – Follow a policy into the registry'
    module: 'Day 1 – Troubleshooting enrollment and configuration'
---

# Exercise 4.1 – Follow a policy into the registry

**Estimated time:** 30 minutes

**Goal:** Trace one user setting and one device setting all the way from the portal through the SyncML stream into the registry.

1. On CL3, install SyncML Viewer, start it and keep it running.

   ```cmd
   winget install syncmlviewer
   ```

2. In the Intune admin center, go to Devices → Manage devices → Configuration → Create → New policy → Windows 10 and later → Settings catalog and create two policies:

   | Policy | Setting | Value | Assign to |
   |---|---|---|---|
   | `flaneX-User` | Administrative Templates → Control Panel → Personalization → **Prevent changing theme (User)** | Enabled | `studentXusers` |
   | `flaneX-Device` | Start → **Hide Recently Added Apps (Device)** | Hide | `studentXdevices` |
   | `flaneX-Device` | Config Refresh | Enabled, cadence 30 minutes | (same policy) |

3. Sync CL3 under Settings → Accounts → Access work or school → your account → Info → Sync.
4. In SyncML Viewer, press `F3` to search the stream – you won't find search in the menu. Look for `DisableThemeChange` and `HideRecentlyAddedApps` and check whether the `LocURI` of each reads `./User/…` or `./Device/…`.
5. On CL3, open `regedit` elevated, go to `HKLM\SOFTWARE\Microsoft\PolicyManager\current` and locate both values.
6. Back in the Intune admin center, open both policies and review the per-setting status for CL3.

### Checkpoint

- [ ] SyncML Viewer shows both settings
- [ ] `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start` contains `HideRecentlyAddedApps` = `1`
- [ ] CL3 reports **Succeeded** for both policies

### Good to know

- **Config Refresh lives elsewhere:** it is a setting of the MDM client itself (DMClient CSP), not of the Policy CSP, so `PolicyManager` doesn't contain it.
- **Start menu lag:** `Hide Recently Added Apps` takes effect in the Start menu only after a restart, while the registry value appears right after the sync.

**Background:** The portal's sync status is the service's view; the registry shows what the device really applied. `PolicyManager\providers\<GUID>\default\Device\<area>` holds the values Intune delivered – that GUID is one of your two enrollment GUIDs from Exercise 3.1. `PolicyManager\current\device` holds the merged result Windows applies.
