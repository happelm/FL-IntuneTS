---
redirect_from:
  - /Instructions/Labs/LAB_08_1_windows-hello-and-cloud-kerberos.html
title: 'Exercise 8.1 – Reach file shares with Windows Hello'
lab:
    title: 'Exercise 8.1 – Reach file shares with Windows Hello'
    module: 'Day 2 – Troubleshooting apps, compliance and security'
---

# Exercise 8.1 – Reach file shares with Windows Hello

**Estimated time:** 10 minutes

**Goal:** Sign in with Windows Hello and reach an Azure file share with no password prompt.

1. On CL4, sign out and sign back in with the Windows Hello PIN from Exercise 0.1.
2. Still on CL4, check the SSO state.

   ```cmd
   dsregcmd /status
   ```

3. Open the Azure file share `\\flane.file.core.windows.net\labfiles` on CL4 (the share from Exercise 2.1). It is reachable only from CL3 and CL4.
4. Then list your Kerberos tickets on CL4.

   ```cmd
   klist
   ```

5. The trainer demonstrates access to on-premises resources in `training.flane` (`\\dc1.training.flane\labfiles`) with the same sign-in.

<!-- VERIFY: OnPremTgt = YES in the Fastlane pod without line of sight to DC1 -->

### Checkpoint

- [ ] In the SSO State section of `dsregcmd /status`, `AzureAdPrt`, `CloudTgt` and `OnPremTgt` all read `YES`
- [ ] The Azure file share opens with no password prompt, and `klist` lists a ticket for the storage account (`cifs/flane.file.core.windows.net`)

### Good to know

- **Already set up:** Microsoft Entra Kerberos and Windows Hello for Business are enabled in the training tenant.
- **Two tickets:** `CloudTgt` is the cloud Kerberos ticket for cloud resources such as Azure Files; `OnPremTgt` is the one for on-premises resources. Your clients can't see the domain controller in `training.flane`, so the trainer shows on-premises access.

**Background:** No PRT, no SSO. Begin with `dsregcmd /status` every time, before you look at the network or the file server.
