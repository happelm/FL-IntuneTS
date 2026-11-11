# Labfiles

| File | Lab | Purpose |
|---|---|---|
| `Autoenroll.ps1` | 0.1 | Fallback when MDM auto-enrollment did not run: sets the Intune enrollment URLs and enrolls the device as corporate device |
| `cmtrace.intunewin` | 5.1 | Win32 app `flaneX-CMTrace`, ready to upload: contains `cmtrace.exe`, `CmtraceInstall.ps1` and `CmtraceRemove.ps1` |
| `CmtraceInstall.ps1`, `CmtraceRemove.ps1` | 5.1 | Install and uninstall script inside `cmtrace.intunewin`, for reference (script by Jorgen, CCMexec.com) |
| `Detect-ReinstallCMTrace.ps1`, `Remediate-ReinstallCMTrace.ps1` | 6.2 | Remediation `flaneX-Reinstall-CMTrace`, run on demand: removes the detection file of `flaneX-CMTrace` and lets the IME reinstall it |
| `Demos\ConfigureSCP.ps1` | Demos | Service connection point for Microsoft Entra hybrid join (demo: Hybrid join and Microsoft Entra Kerberos) |
| `Demos\Set-KeyboardUS.ps1` | Demos | English (US) keyboard on CL1/CL2 for the remote lab: current user, welcome screen, system accounts, new users and every user at sign-in |
| `createtestfolder.ps1` | 6.1 | Platform script `flaneX-Folder`: creates `C:\TestFolder` |
| `Detect-LabKey.ps1`, `Remediate-LabKey.ps1` | 6.1 | Remediation `flaneX-Reg`: replace `flaneX` in the registry key `HKLM\SOFTWARE\flaneX\Lab` with your user name (for example `flane3`) before you upload |
| `Toolbox\Get-IntunePolicyAssignmentsByGroup.ps1` | 13.2, 16.1 | Read-only: every Intune object that reaches a group, a device (`-DeviceName`) or a user (`-UserPrincipalName`) |
| `Toolbox\Find-UnassignedIntuneObjects.ps1` | 13.2 | Read-only: Intune objects without assignment, with exclusions only or with deleted groups only |
| `Toolbox\Export-IntuneReport.ps1`, `Toolbox\ReportPresets.json` | 13.2, 13.3 | Exports an Intune report through the Graph exportJobs API as CSV; presets for compliance, compliance trend, remediation results and app install status |
| `Toolbox\DataWarehouse\ComplianceTrend.pq`, `Toolbox\DataWarehouse\Devices.pq` | 13.3 | Power Query for Excel: compliance trend per day and device list with last sync from the Intune Data Warehouse OData feed |

CMTrace for Lab 2.1 is on the Azure file share `\\flane.file.core.windows.net\labfiles` (reachable from CL3 and CL4 only). SyncML Viewer for Lab 4.1 is installed with `winget install syncmlviewer`.
