---
title: 'Lab 10.1 – Troubleshoot with Microsoft Graph'
lab:
    title: 'Lab 10.1 – Troubleshoot with Microsoft Graph'
    module: 'Day 2 – Apps, protect, support'
---

# Lab 10.1 – Troubleshoot with Microsoft Graph

**Estimated time:** 30 minutes

**Goal:** Answer the first questions of a support case for CL3 in Graph Explorer – which device, which objects, which groups, which policies, what changed – and sync the device.

**Why:** The Intune admin center spreads these answers over many pages, and some it does not show at all: the Entra object behind a device, nested group memberships, every change of the day in one list. Graph returns them in one call each – and a call you built once becomes a script.

Open Graph Explorer (`https://aka.ms/ge`) and sign in with your user `etcX`. The method (GET, POST, …) is a drop-down left of the URL box: set it there, clear the URL box and paste only the URL from the code blocks below. Replace the values in `{braces}`.

### Part A – Which device, which objects

1. Method **GET** – find CL3 in Intune. Note `id` (Intune device ID) and `azureADDeviceId`:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=deviceName eq 'CL3-yourname'&$select=id,deviceName,userPrincipalName,azureADDeviceId,deviceEnrollmentType,managementAgent,complianceState,enrolledDateTime,lastSyncDateTime
   ```

   `managementAgent` tells you who manages the device: `mdm` is Intune only, `configurationManagerClientMdm` is co-managed.

2. Method **GET** – find the Entra ID object with the `azureADDeviceId`. Note its `id` – the Entra object ID is a different ID than the Intune device ID and the device ID:

   ```text
   https://graph.microsoft.com/v1.0/devices?$filter=deviceId eq '{azureADDeviceId}'&$select=id,deviceId,displayName,trustType,accountEnabled,registrationDateTime,approximateLastSignInDateTime
   ```

3. Method **GET** – are there more Entra objects with the same name? Every object beyond the first is a leftover from an earlier enrollment or join:

   ```text
   https://graph.microsoft.com/v1.0/devices?$filter=displayName eq 'CL3-yourname'&$select=id,deviceId,trustType,accountEnabled,registrationDateTime
   ```

### Part B – Why is something applied, or not

4. Method **GET** – all groups CL3 is a member of, including nested groups. Use the Entra object ID from step 2:

   ```text
   https://graph.microsoft.com/v1.0/devices/{Entra object id}/transitiveMemberOf?$select=displayName
   ```

   Is `studentXdevices` in the list? A policy or app assigned to a group that is missing here never reaches the device.

5. Method **GET** – compliance state per compliance policy:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/deviceCompliancePolicyStates
   ```

6. Method **GET** – state per configuration profile:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/deviceConfigurationStates
   ```

   Compare with the Intune admin center → Devices → `CL3-yourname` → Device configuration. Which profiles are missing in the Graph result, and which ones show up twice?

### Part C – What changed, and act

7. Method **GET** – every change to apps since this morning: who, when, which object. Replace the date with today:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/auditEvents?$filter=activityDateTime ge 2026-10-16T00:00:00Z and componentName eq 'MobileApp'&$select=activityDateTime,activityType,actor,resources&$top=20
   ```

   Run it again with `componentName eq 'DeviceConfiguration'` and `componentName eq 'ManagedDevices'`. Find your own changes from Lab 5.1 and 6.1.

8. Method **POST**, request body empty – sync CL3, then run step 1 again a few minutes later and compare `lastSyncDateTime`:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/syncDevice
   ```

### Checkpoint

- [ ] Intune device ID, device ID and Entra object ID of CL3 noted – three different IDs
- [ ] Number of Entra objects named `CL3-yourname` checked
- [ ] `studentXdevices` found in the group list of CL3
- [ ] Your own changes from today found in the audit events
- [ ] Sync triggered through Graph, `lastSyncDateTime` updated

**Note:** In Graph Explorer, **Code snippets** next to the response shows the PowerShell command for the same request – the step from a query to a script.

**Note:** Graph Explorer asks for permissions when you sign in; in this tenant the trainer has granted them in advance. Your Intune role still decides what you see: the audit events need the permission to read audit data, and you only see the devices your role covers.

**Why three IDs:** Intune, Entra ID and the device each have their own: `id` in Intune, `deviceId` (written to the device at join or registration, shown by `dsregcmd /status`) and `id` in Entra ID. Support tools, logs and portals use different ones – mixing them up is a classic dead end.
