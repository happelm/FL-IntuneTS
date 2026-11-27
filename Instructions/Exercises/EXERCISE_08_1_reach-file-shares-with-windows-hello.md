---
redirect_from:
  - /Instructions/Labs/LAB_08_1_windows-hello-and-cloud-kerberos.html
title: 'Exercise 8.1 – Reach file shares with Windows Hello'
lab:
    title: 'Exercise 8.1 – Reach file shares with Windows Hello'
    module: 'Day 2 – Apps, protect, support'
---

# Exercise 8.1 – Reach file shares with Windows Hello

**Estimated time:** 10 minutes

**Goal:** Sign in with Windows Hello and open an Azure file share without a password prompt.

1. CL4: sign out and sign in again with the Windows Hello PIN you set up in Exercise 0.1.
2. CL4: check the SSO state.

   ```cmd
   dsregcmd /status
   ```

3. CL4: open the Azure file share `\\flane.file.core.windows.net\labfiles` (the share you used in Exercise 2.1). It works only from CL3 and CL4.
4. CL4: list your Kerberos tickets.

   ```cmd
   klist
   ```

5. Trainer demo: access to on-premises resources in `training.flane` (`\\dc1.training.flane\labfiles`) with the same sign-in.

<!-- VERIFY: OnPremTgt = YES in the Fastlane pod without line of sight to DC1 -->

### Checkpoint

- [ ] `dsregcmd /status`, section SSO State: `AzureAdPrt`, `CloudTgt` and `OnPremTgt` are `YES`
- [ ] Azure file share opens without a password prompt, `klist` shows a ticket for the storage account (`cifs/flane.file.core.windows.net`)

**Note:** Microsoft Entra Kerberos and Windows Hello for Business are already enabled in the training tenant. `CloudTgt` is the cloud Kerberos ticket for cloud resources such as Azure Files, `OnPremTgt` the one for on-premises resources. Your clients have no line of sight to the domain controller in `training.flane`, so on-premises access is shown by the trainer.

**Why:** No PRT, no SSO. Always start with `dsregcmd /status` before you look at the network or the file server.
