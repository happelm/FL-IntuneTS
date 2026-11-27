---
redirect_from:
  - /Instructions/Labs/LAB_07_1_trace-a-compliance-block.html
title: 'Exercise 7.1 – Break and repair compliance'
lab:
    title: 'Exercise 7.1 – Break and repair compliance'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 7.1 – Break and repair compliance

**Estimated time:** 30 minutes

**Goal:** Push CL3 into noncompliance on purpose, experience what the user sees and then fix it. The trainer shows the same block in the sign-in log.

1. On CL3, run `ver` and write down the OS version.
2. In the Intune admin center, go to Devices → Manage devices → Compliance → Create policy → Windows 10 and later and create the compliance policy `flaneX-MinOS`: Device properties → Operating system version → **Minimum OS version** `10.0.26400.0`, assigned to `studentXusers`.
3. On CL3, open the Company Portal, select **Check access** and wait for the device to turn noncompliant.
4. In the Intune admin center, open Devices → All devices → `CL3-yourname` → Device compliance and find `flaneX-MinOS` together with the failing setting.
5. On CL3, sign in to Microsoft Edge as `flaneX` and open `office.com`. The trainer's Conditional Access policy blocks the noncompliant device.
6. The trainer then walks through the sign-in log of your attempt – Conditional Access tab, Device info, What If.
7. To clean up, lower the minimum OS version in `flaneX-MinOS` to the version from step 1 (or below) and run **Check access** again – `office.com` now opens.

### Checkpoint

- [ ] CL3 is noncompliant, with minimum OS version as the reason
- [ ] On CL3, `office.com` is blocked with a compliance message
- [ ] CL3 is compliant again and `office.com` opens

### Good to know

- **Version format:** the minimum OS version is written as `major.minor.build.revision` – the same value `ver` displays.

**Background:** Intune evaluates compliance; Microsoft Entra ID enforces the block. Your role doesn't cover Conditional Access, which is why the sign-in log is part of the trainer demo.
