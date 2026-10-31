---
title: Intune-TS Lab Instructions
permalink: index.html
---

# Intune-TS – Troubleshooting Microsoft Intune

Lab instructions for the three-day Intune-TS troubleshooting workshop. Use the copy button on every code block.

## Labs

### Day 1 – Method, enroll, configure

Troubleshooting method and service-side tools, log files, registration and enrollment, RBAC, policy processing and conflicts.

| Lab | Title | Time |
|---|---|---|
| 0.1 | [Set up your lab](Instructions/Labs/LAB_00_1_set-up-your-lab.html) | 20 min |
| 2.1 | [Collect and read Intune logs](Instructions/Labs/LAB_02_1_collect-and-read-intune-logs.html) | 30 min |
| 3.1 | [Check the enrollment state](Instructions/Labs/LAB_03_1_check-the-enrollment-state.html) | 25 min |
| 4.1 | [Trace a policy to the registry](Instructions/Labs/LAB_04_1_trace-a-policy-to-the-registry.html) | 30 min |

### Day 2 – Apps, protect, support

App deployment and the Intune Management Extension, scripts and remediations, compliance and Conditional Access, SSO and Microsoft Entra Kerberos, legacy management conflicts (demo), support, retire and community tools, endpoint security and Microsoft Defender for Endpoint on the client.

| Lab | Title | Time |
|---|---|---|
| 5.1 | [Trace a Win32 app](Instructions/Labs/LAB_05_1_trace-a-win32-app.html) | 45 min |
| 5.2 | [Force the reinstall of a required app](Instructions/Labs/LAB_05_2_force-the-reinstall-of-a-required-app.html) | 25 min |
| 6.1 | [Trace a platform script and a remediation](Instructions/Labs/LAB_06_1_trace-a-platform-script-and-a-remediation.html) | 40 min |
| 7.1 | [Trace a compliance block](Instructions/Labs/LAB_07_1_trace-a-compliance-block.html) | 30 min |
| 8.1 | [Windows Hello and cloud Kerberos](Instructions/Labs/LAB_08_1_windows-hello-and-cloud-kerberos.html) | 45 min |
| 11.1 | [Troubleshoot endpoint security](Instructions/Labs/LAB_11_1_troubleshoot-endpoint-security.html) (draft) | 75 min |

### Day 3 – Advanced troubleshooting and scripting

Windows LAPS and Endpoint Privilege Management on the client; Microsoft Graph and a script toolbox for support cases; compliance history from reports, the Data Warehouse and the audit log; writing and checking scripts with AI; a read-only look at iOS and Android devices; demos of change audit, Device query and Remote Help; a final partner case with scenarios from all three days.

| Lab | Title | Time |
|---|---|---|
| 12.1 | [Troubleshoot LAPS and EPM](Instructions/Labs/LAB_12_1_troubleshoot-laps-and-epm.html) (draft) | 60 min |
| 13.1 | [Troubleshoot with Microsoft Graph](Instructions/Labs/LAB_13_1_troubleshoot-with-microsoft-graph.html) | 30 min |
| 13.2 | [Build your troubleshooting toolbox](Instructions/Labs/LAB_13_2_build-your-troubleshooting-toolbox.html) (draft) | 90 min |
| 13.3 | [Prove when it broke](Instructions/Labs/LAB_13_3_prove-when-it-broke.html) (draft, if time permits) | 30 min |
| 14.1 | [Write troubleshooting scripts with AI](Instructions/Labs/LAB_14_1_write-troubleshooting-scripts-with-ai.html) (draft) | 60 min |
| 15.1 | [Read a mobile device](Instructions/Labs/LAB_15_1_read-a-mobile-device.html) (draft, if time permits) | 30 min |
| 16.1 | [Partner breaks, you fix](Instructions/Labs/LAB_16_1_partner-breaks-you-fix.html) (draft) – final case with scenarios from all three days | 60 min |

### Appendix

[Log map, collecting logs](Instructions/Appendix.html)

### Resources

[Intune-TS link collection](https://github.com/happelm/Intune-Resources/blob/main/Intune3Links.md) – Learn articles, blogs and tools for this workshop.

## About this guide

This is not a break-and-fix course. You first look at how a healthy device behaves and logs – a deviation then shows you where to look. Each lab lists its goal, the steps at task level (not every click) and a checkpoint you confirm before moving on.

- **Steps** say what to do and where. Menu paths use → between levels.
- **Checkpoint** items are the definition of done. If one fails, tell the trainer before you continue – later labs build on your enrolled CL3 and CL4.
- **Notes** explain what to expect and where it typically goes wrong.

### Your lab environment

One shared training tenant – your objects carry your number, nobody touches another participant's objects. Your clients join Microsoft Entra ID natively and enroll in Intune – no domain join, no Configuration Manager.

| System | Role | Note |
|---|---|---|
| Tenant | Shared training tenant of the trainer | You are user `studentX`; your groups are `studentXdevices` and `studentXusers` |
| CL3, CL4 | Windows 11 – your clients | Start at OOBE; renamed to `CL3-yourname` / `CL4-yourname`, Entra joined and enrolled by you in Lab 0.1 |
| DC1 | AD DS, DNS – domain `training.flane` (trainer's pod) | Source of the synced lab users; on-premises access is a trainer demo (Lab 8.1) |
| SRV1 | Member server in `training.flane` (trainer's pod) | Trainer demo only |
| Azure file share | `\\flane.file.core.windows.net\labfiles` – Microsoft Entra Kerberos | Lab files; reachable from CL3 and CL4 only, no line of sight to `training.flane` needed (Labs 2.1, 8.1) |

X is your participant number from `course.txt`. Passwords are handed out by the trainer.

### Naming

Every policy, profile, app and script you create starts with `studentX-` (for example `student3-CMTrace`), so every object is unique and you find your own.

### Your permissions

All roles are assigned to your group `studentXusers`, never to you directly.

| Where | Role | You can |
|---|---|---|
| Entra ID | User Administrator, Authentication Administrator – admin unit *Lab-Student Group Administrators* | Manage the student device groups, e.g. add CL3 and CL4 to `studentXdevices` |
| Entra ID | Cloud Device Administrator – admin unit *Lab-Student Device Administrators* | Enable, disable and delete lab devices |
| Intune | Lab-Reader for Students | See everything, change nothing |
| Intune | Lab-Administrator for Students | Create, change, assign and delete objects tagged *Lab-Students*, assign to the student groups only |

Not for you: roles, scope tags, tenant settings, Conditional Access. Assignment filters are read only. Your roles reach the lab groups and lab devices of every participant – touch only your own.

### Tools

- CMTrace for all .log files – from `\\flane.file.core.windows.net\labfiles` (CL3/CL4 only) in Lab 2.1, deployed by Intune in Lab 5.1. Intune Management Extension logs in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`
- Intune admin center: intune.microsoft.com · Entra admin center: entra.microsoft.com
- Lab files: [Labfiles folder in this repository](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles)
