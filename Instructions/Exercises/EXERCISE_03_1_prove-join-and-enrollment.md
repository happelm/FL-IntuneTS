---
redirect_from:
  - /Instructions/Labs/LAB_03_1_check-the-enrollment-state.html
title: 'Exercise 3.1 – Prove join and enrollment'
lab:
    title: 'Exercise 3.1 – Prove join and enrollment'
    module: 'Day 1 – Troubleshooting enrollment and configuration'
---

# Exercise 3.1 – Prove join and enrollment

**Estimated time:** 25 minutes

**Goal:** Show from the device itself that CL3 is joined and enrolled – and learn where each of those facts lives.

1. On CL3, run `dsregcmd /status` and look at `AzureAdJoined` and `AzureAdPrt`.
2. Still on CL3, open Settings → Accounts → Access work or school → your account → **Info** and write down the management server and the last sync.
3. In an elevated session on CL3, open Task Scheduler → Microsoft → Windows → EnterpriseMgmt. There are two GUID folders, one for the MDM enrollment and one for MMP-C. Write down both GUIDs.
4. Then open `regedit` (elevated), go to `HKLM\SOFTWARE\Microsoft\Enrollments` and locate the keys that match the two GUIDs from step 3.

### Checkpoint

- [ ] `AzureAdJoined : YES` and `AzureAdPrt : YES`
- [ ] The two GUIDs from Task Scheduler reappear under `HKLM\SOFTWARE\Microsoft\Enrollments`

### Good to know

- **Admins only:** Task Scheduler shows the EnterpriseMgmt tasks to administrators only. The GUIDs differ on every client, which is why Task Scheduler is where you look them up. `HKLM\SOFTWARE\Microsoft\Enrollments` contains more keys than these two.

**Background:** Everything that follows hinges on the enrollment GUID, because Intune policies are stored per provider GUID. In Exercise 4.1, one of your two GUIDs turns up under `PolicyManager`.

**Reference:** [Diagnose MDM enrollment](https://learn.microsoft.com/en-us/windows/client-management/mdm-diagnose-enrollment) on Microsoft Learn – skip the Group Policy part, it doesn't apply to your Entra-joined clients.
