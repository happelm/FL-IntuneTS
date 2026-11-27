---
redirect_from:
  - /Instructions/Labs/LAB_03_1_check-the-enrollment-state.html
title: 'Exercise 3.1 – Prove join and enrollment'
lab:
    title: 'Exercise 3.1 – Prove join and enrollment'
    module: 'Day 1 – Method, enroll, configure'
---

# Exercise 3.1 – Prove join and enrollment

**Estimated time:** 25 minutes

**Goal:** Prove from the device side that CL3 is joined and enrolled – and know where each fact is stored.

1. CL3: run `dsregcmd /status` and check `AzureAdJoined` and `AzureAdPrt`.
2. CL3: Settings → Accounts → Access work or school → your account → **Info**. Note the management server and the last sync.
3. CL3, elevated: Task Scheduler → Microsoft → Windows → EnterpriseMgmt. You find two GUID folders – one for the MDM enrollment, one for MMP-C. Note both GUIDs.
4. CL3, elevated: open `regedit` and go to `HKLM\SOFTWARE\Microsoft\Enrollments` – find the keys with the two GUIDs from step 3.

### Checkpoint

- [ ] `AzureAdJoined : YES` and `AzureAdPrt : YES`
- [ ] Two GUIDs in Task Scheduler, the same two GUIDs under `HKLM\SOFTWARE\Microsoft\Enrollments`

**Note:** Task Scheduler shows the EnterpriseMgmt tasks only to administrators. The GUIDs are different on every client – Task Scheduler is the place to find them. `HKLM\SOFTWARE\Microsoft\Enrollments` holds more keys than these two.

**Why:** The enrollment GUID is the key for everything that follows: Intune policies are stored per provider GUID – in Exercise 4.1 you find one of your two GUIDs under `PolicyManager`.

**Reference:** [Diagnose MDM enrollment](https://learn.microsoft.com/en-us/windows/client-management/mdm-diagnose-enrollment) on Microsoft Learn – the Group Policy part does not apply to your Entra-joined clients.
