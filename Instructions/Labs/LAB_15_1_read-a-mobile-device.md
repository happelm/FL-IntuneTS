---
title: 'Lab 15.1 – Read a mobile device'
lab:
    title: 'Lab 15.1 – Read a mobile device'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Lab 15.1 – Read a mobile device

**Estimated time:** 30 minutes (if time permits)

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Use the method of this course on iOS/iPadOS and Android – scope, state, evidence – without touching a device.

**Starting point:** The trainer's iPhone, iPad and Android devices are enrolled in the training tenant. You only read: your role lets you see every device, but you don't change anything and you don't run remote actions on these devices. The trainer tells you which user the devices belong to.

### Part A – Which devices, which enrollment

1. Intune admin center → Devices → **iOS/iPadOS** and **Android**: find the trainer's devices. Note for each: OS version, ownership, last check-in.
2. Graph Explorer, method **GET** – the same in one call (Lab 13.1):

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=operatingSystem eq 'iOS' or operatingSystem eq 'Android'&$select=deviceName,operatingSystem,osVersion,deviceEnrollmentType,managedDeviceOwnerType,complianceState,lastSyncDateTime
   ```

   Which enrollment type does each device have? An iPad and an iPhone can be enrolled in different ways – that decides what Intune can manage on them.

### Part B – Is the user OK?

3. Intune admin center → Troubleshooting + support → **Troubleshoot** → Select user: the trainer's user. Check:
   - **Intune license** – green check
   - Per device: **Managed** (MDM or EAS/MDM), **Microsoft Entra join type**, **Intune compliant**, **Microsoft Entra compliant**, **Last check-in**
4. Which device has the oldest check-in? By default devices check in every 8 hours – more than 24 hours points to a device that is off, offline or no longer managed.

### Part C – Why a setting doesn't apply

5. Open one mobile device → **Device compliance** and **Device configuration**. Note every status that is not *Succeeded* or *Compliant*.
6. For one policy with an unusual status, find the reason:

   | Status | Meaning |
   |---|---|
   | Not applicable | The setting or the profile does not fit this platform or enrollment type |
   | Conflict | Two policies set the same setting with different values, or the device has a setting Intune can't override |
   | Pending | The device has not checked in since the assignment, or has not reported the result yet |
   | Error | Look up the error code |

7. Devices → Compliance → open a compliance policy that targets the mobile devices → **Per-setting status**: which setting makes a device noncompliant?

### Part D – Logs from the device (trainer demo)

8. The trainer shows the user side:
   - iOS/iPadOS: Company Portal → **More** → **Send Logs** – the incident ID goes to the helpdesk
   - Android with work profile: Company Portal → **Help** → **Send logs**
   - Android fully managed: Microsoft Intune app → **Help** → **Get Support** → **Upload logs**
9. Intune admin center → Troubleshooting + support → **Diagnostics**: the logs the Android device just uploaded. iOS logs go to Microsoft support with the incident ID – they don't appear here.

### Checkpoint

- [ ] Enrollment type, ownership and last check-in of every mobile device noted
- [ ] Troubleshoot pane read for the trainer's user
- [ ] One status other than *Succeeded* explained
- [ ] You can name where the logs of an iPhone and of an Android device end up

**Note:** Android enrollment types (work profile, fully managed, dedicated) and Apple enrollment types (Automated Device Enrollment, device enrollment, user enrollment) support different settings. *Not applicable* is often not an error but the wrong profile type for the enrollment.

**Why:** Mobile tickets start with the same questions as Windows tickets – is the user licensed, is the device in scope, did it check in, which setting failed. Only the logs are harder to get, so the portal and Graph do more of the work.

<!-- VERIFY: Lab-Reader for Students can open Troubleshooting + support → Troubleshoot and → Diagnostics -->
<!-- VERIFY: Graph $filter with "or" on operatingSystem works for managedDevices (otherwise two calls) -->
<!-- VERIFY: menu names in Company Portal / Intune app on the trainer's current app versions -->
<!-- Sources: learn.microsoft.com/troubleshoot/mem/intune/device-configuration/troubleshoot-policies-in-microsoft-intune (Troubleshoot pane, 8 h check-in, statuses); learn.microsoft.com/intune/user-help/diagnostics/collect-logs-ios and collect-logs-android; learn.microsoft.com/intune/app-management/configuration/configure-company-portal (Diagnostics: Android, AOSP, Windows Company Portal logs) -->
