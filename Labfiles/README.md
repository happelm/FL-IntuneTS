# Labfiles

| File | Lab | Purpose |
|---|---|---|
| `Autoenroll.ps1` | 0.1 | Fallback when MDM auto-enrollment did not run: sets the Intune enrollment URLs and enrolls the device as corporate device |
| `cmtrace.intunewin` | 5.1 | Win32 app `studentX-CMTrace`, ready to upload: contains `cmtrace.exe`, `CmtraceInstall.ps1` and `CmtraceRemove.ps1` |
| `CmtraceInstall.ps1`, `CmtraceRemove.ps1` | 5.1 | Install and uninstall script inside `cmtrace.intunewin`, for reference (script by Jorgen, CCMexec.com) |
| `Detect-ReinstallCMTrace.ps1`, `Remediate-ReinstallCMTrace.ps1` | 5.2 | Remediation `studentX-Reinstall-CMTrace`, run on demand: removes the detection file of `studentX-CMTrace` and lets the IME reinstall it |
| `createtestfolder.ps1` | 6.1 | Platform script `studentX-Folder`: creates `C:\TestFolder` |
| `Detect-LabKey.ps1`, `Remediate-LabKey.ps1` | 6.1 | Remediation `studentX-Reg`: replace `studentX` with your prefix before you upload |
| `Toolbox\Get-IntunePolicyAssignmentsByGroup.ps1` | 13.2, 16.1 | Read-only: every Intune object that reaches a group, a device (`-DeviceName`) or a user (`-UserPrincipalName`) |
| `Toolbox\Find-UnassignedIntuneObjects.ps1` | 13.2 | Read-only: Intune objects without assignment, with exclusions only or with deleted groups only |
| `Toolbox\Export-IntuneReport.ps1`, `Toolbox\ReportPresets.json` | 13.2, 13.3 | Exports an Intune report through the Graph exportJobs API as CSV; presets for compliance, compliance trend, remediation results and app install status |
| `Toolbox\DataWarehouse\ComplianceTrend.pq`, `Toolbox\DataWarehouse\Devices.pq` | 13.3 | Power Query for Excel: compliance trend per day and device list with last sync from the Intune Data Warehouse OData feed |

CMTrace for Lab 2.1 is on the Azure file share `\\flane.file.core.windows.net\labfiles` (reachable from CL3 and CL4 only). SyncML Viewer for Lab 4.1 is installed with `winget install syncmlviewer`.
