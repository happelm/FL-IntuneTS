---
redirect_from:
  - /Instructions/Labs/LAB_15_1_read-a-mobile-device.html
title: 'Exercise 15.1 – Read a mobile device'
lab:
    title: 'Exercise 15.1 – Read a mobile device'
    module: 'Day 3 – Advanced troubleshooting and scripting'
---

# Exercise 15.1 – Read a mobile device

**Estimated time:** 30 minutes (if time permits)

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Apply the method of this course – scope, state, evidence – to iOS/iPadOS and Android, without touching a device.

**Starting point:** The trainer's iPhone, iPad and Android devices are enrolled in the training tenant. You only read: your role shows you every device, but you change nothing and run no remote actions on these devices. The trainer tells you which user owns them.

### Part A – Which devices, which enrollment

1. In the Intune admin center, open Devices → **iOS/iPadOS** and **Android** and find the trainer's devices. For each one, write down OS version, ownership and last check-in.
2. In Graph Explorer, get the same with a single **GET** call (Exercise 13.1):

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=operatingSystem eq 'iOS' or operatingSystem eq 'Android'&$select=deviceName,operatingSystem,osVersion,deviceEnrollmentType,managedDeviceOwnerType,complianceState,lastSyncDateTime
   ```

   What enrollment type does each device have? An iPad and an iPhone can be enrolled differently, and that determines what Intune can manage on them.

### Part B – Is the user OK?

3. In the Intune admin center, go to Troubleshooting + support → **Troubleshoot**, choose Select user and pick the trainer's user. Check:
   - **Intune license** – green check
   - For each device: **Managed** (MDM or EAS/MDM), **Microsoft Entra join type**, **Intune compliant**, **Microsoft Entra compliant**, **Last check-in**
4. Which device checked in longest ago? Devices check in every 8 hours by default – more than 24 hours suggests a device that is off, offline or no longer managed.

### Part C – Why a setting doesn't apply

5. Open one mobile device and go to **Device compliance** and **Device configuration**. Write down every status other than *Succeeded* or *Compliant*.
6. Pick one policy with an unusual status and find the reason:

   | Status | Meaning |
   |---|---|
   | Not applicable | The setting or the profile does not fit this platform or enrollment type |
   | Conflict | Two policies set the same setting with different values, or the device has a setting Intune can't override |
   | Pending | The device has not checked in since the assignment, or has not reported the result yet |
   | Error | Look up the error code |

7. Under Devices → Compliance, open a compliance policy that targets the mobile devices and go to **Per-setting status**: which setting makes a device noncompliant?

### Part D – Logs from the device (trainer demo)

8. The trainer shows the user side:
   - iOS/iPadOS: Company Portal → **More** → **Send Logs** – the incident ID goes to the helpdesk
   - Android with work profile: Company Portal → **Help** → **Send logs**
   - Android fully managed: Microsoft Intune app → **Help** → **Get Support** → **Upload logs**
9. In the Intune admin center under Troubleshooting + support → **Diagnostics**, you see the logs the Android device just uploaded. iOS logs go to Microsoft support under the incident ID and don't appear here.

### Checkpoint

- [ ] You noted enrollment type, ownership and last check-in for every mobile device
- [ ] You read the Troubleshoot pane for the trainer's user
- [ ] You can explain one status other than *Succeeded*
- [ ] You know where the logs of an iPhone and of an Android device end up

### Good to know

- **Enrollment type decides:** Android enrollment types (work profile, fully managed, dedicated) and Apple enrollment types (Automated Device Enrollment, device enrollment, user enrollment) support different settings. *Not applicable* is often no error at all, just the wrong profile type for the enrollment.

**Background:** Mobile tickets open with the same questions as Windows tickets – is the user licensed, is the device in scope, did it check in, which setting failed. Only the logs are harder to get, so the portal and Graph carry more of the load.

<!-- VERIFY: Lab-Reader for Students can open Troubleshooting + support → Troubleshoot and → Diagnostics -->
<!-- VERIFY: Graph $filter with "or" on operatingSystem works for managedDevices (otherwise two calls) -->
<!-- VERIFY: menu names in Company Portal / Intune app on the trainer's current app versions -->
<!-- Sources: learn.microsoft.com/troubleshoot/mem/intune/device-configuration/troubleshoot-policies-in-microsoft-intune (Troubleshoot pane, 8 h check-in, statuses); learn.microsoft.com/intune/user-help/diagnostics/collect-logs-ios and collect-logs-android; learn.microsoft.com/intune/app-management/configuration/configure-company-portal (Diagnostics: Android, AOSP, Windows Company Portal logs) -->
