---
redirect_from:
  - /Instructions/Labs/LAB_13_1_troubleshoot-with-microsoft-graph.html
title: 'Exercise 13.1 – Troubleshoot with Microsoft Graph'
lab:
    title: 'Exercise 13.1 – Troubleshoot with Microsoft Graph'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 13.1 – Troubleshoot with Microsoft Graph

**Estimated time:** 30 minutes

**Goal:** Use Graph Explorer to answer the opening questions of a support case for CL3 – which device, which objects, which groups, which policies, what changed – and then sync the device.

**Background:** The Intune admin center spreads these answers across many pages, and some of them it doesn't show at all: the Entra object behind a device, nested group memberships, every change of the day in a single list. Graph returns each of them with one call – and a call you built once turns into a script.

Open Graph Explorer (`https://aka.ms/ge`) and sign in as `flaneX`. The method (GET, POST, …) is the drop-down to the left of the URL box: set it there, empty the URL box and paste just the URL from the code blocks below. Replace the values in `{braces}`.

### Part A – Which device, which objects

1. With method **GET**, find CL3 in Intune and write down `id` (Intune device ID) and `azureADDeviceId`:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=deviceName eq 'CL3-yourname'&$select=id,deviceName,userPrincipalName,azureADDeviceId,deviceEnrollmentType,managementAgent,complianceState,enrolledDateTime,lastSyncDateTime
   ```

   `managementAgent` shows who manages the device: `mdm` means Intune only, `configurationManagerClientMdm` means co-managed.

2. With method **GET**, look up the Entra ID object by its `azureADDeviceId` and write down its `id`. The Entra object ID differs from both the Intune device ID and the device ID:

   ```text
   https://graph.microsoft.com/v1.0/devices?$filter=deviceId eq '{azureADDeviceId}'&$select=id,deviceId,displayName,trustType,accountEnabled,registrationDateTime,approximateLastSignInDateTime
   ```

3. With method **GET**, check for further Entra objects with the same name. Every object after the first is left over from an earlier enrollment or join:

   ```text
   https://graph.microsoft.com/v1.0/devices?$filter=displayName eq 'CL3-yourname'&$select=id,deviceId,trustType,accountEnabled,registrationDateTime
   ```

### Part B – Why is something applied, or not

4. With method **GET**, list every group CL3 belongs to, nested groups included. Use the Entra object ID from step 2:

   ```text
   https://graph.microsoft.com/v1.0/devices/{Entra object id}/transitiveMemberOf?$select=displayName
   ```

   Does the list contain `studentXdevices`? A policy or app assigned to a group missing from this list never reaches the device.

5. With method **GET**, get the compliance state for each compliance policy:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/deviceCompliancePolicyStates
   ```

6. With method **GET**, get the state for each configuration profile:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/deviceConfigurationStates
   ```

   Put it next to Intune admin center → Devices → `CL3-yourname` → Device configuration. Which profiles are missing from the Graph result, and which appear twice?

### Part C – What changed, and act

7. With method **GET**, list every app change since yesterday morning – who, when, which object. Replace the date with yesterday's:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/auditEvents?$filter=activityDateTime ge 2026-10-16T00:00:00Z and componentName eq 'MobileApp'&$select=activityDateTime,activityType,actor,resources&$top=20
   ```

   Repeat it with `componentName eq 'DeviceConfiguration'` and `componentName eq 'ManagedDevices'`, and find your own changes from Exercise 5.1 and 6.1 on Day 2.

8. With method **POST** and an empty request body, sync CL3. A few minutes later, run step 1 again and compare `lastSyncDateTime`:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/syncDevice
   ```

### Checkpoint

- [ ] You noted the Intune device ID, device ID and Entra object ID of CL3 – three different IDs
- [ ] You checked how many Entra objects are named `CL3-yourname`
- [ ] The group list of CL3 contains `studentXdevices`
- [ ] The audit events show your own changes from Day 2
- [ ] The sync through Graph updated `lastSyncDateTime`

### Good to know

- **From query to script:** **Code snippets** next to the response shows the PowerShell command for the same request.
- **Permissions:** Graph Explorer asks for permissions at sign-in; in this tenant the trainer granted them beforehand. Your Intune role still limits what you see – the audit events need permission to read audit data, and you only see the devices your role covers.

**Why three IDs:** Intune, Entra ID and the device each keep their own – `id` in Intune, `deviceId` (written to the device at join or registration, shown by `dsregcmd /status`) and `id` in Entra ID. Support tools, logs and portals use different ones, and mixing them up is a classic dead end.
