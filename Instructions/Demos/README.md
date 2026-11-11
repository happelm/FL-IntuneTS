# Demos – overview

Trainer demos and setup checklists for the trainer pod in `training.flane`. Participants work on CL3/CL4 only; everything here is shown by the trainer. Scripts are in [`Labfiles/Demos`](https://github.com/happelm/FL-IntuneTS/tree/main/Labfiles/Demos).

| Demo | Devices | Shows | Needs |
|---|---|---|---|
| [Azure Files share and Microsoft Entra Kerberos](azure-files-entra-kerberos.md) | CL3/CL4 | Lab files share with SSO through Microsoft Entra Kerberos (Labs 2.1 and 8.1) | Setup checklist only after a rebuild |
| [Hybrid join and Microsoft Entra Kerberos](hybrid-join-entra-kerberos.md) | CL1/CL2 | Microsoft Entra hybrid join without computer sync, Windows Hello cloud Kerberos trust, SSO to `\\dc1\labfiles` | DC1 on Windows Server 2025, co-management workloads on Intune |
| [MDM wins over GP demo](mdm-wins-over-gp-demo.md) | CL1 | GPO-01 and Intune set the same SmartScreen setting; registry and event log show which side wins | Hybrid join demo set up, GPO-01 link enabled for the demo |

**Order:** set up the hybrid join demo first; the MDM wins over GP demo builds on it.
