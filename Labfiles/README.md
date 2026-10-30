# Labfiles

| File | Lab | Purpose |
|---|---|---|
| `Autoenroll.ps1` | 0.1 | Fallback when MDM auto-enrollment did not run: sets the Intune enrollment URLs and enrolls the device as corporate device |
| `cmtrace.intunewin` | 5.1 | Win32 app `etcX-CMTrace`, ready to upload: contains `cmtrace.exe`, `CmtraceInstall.ps1` and `CmtraceRemove.ps1` |
| `CmtraceInstall.ps1`, `CmtraceRemove.ps1` | 5.1 | Install and uninstall script inside `cmtrace.intunewin`, for reference (script by Jorgen, CCMexec.com) |
| `Detect-ReinstallCMTrace.ps1`, `Remediate-ReinstallCMTrace.ps1` | 5.2 | Remediation `etcX-Reinstall-CMTrace`, run on demand: removes the detection file of `etcX-CMTrace` and lets the IME reinstall it |
| `createtestfolder.ps1` | 6.1 | Platform script `etcX-Folder`: creates `C:\TestFolder` |
| `Detect-LabKey.ps1`, `Remediate-LabKey.ps1` | 6.1 | Remediation `etcX-Reg`: replace `etcX` with your prefix before you upload |

CMTrace for Lab 2.1 is on the classroom share `\\dc1\labfiles`. SyncML Viewer for Lab 4.1 is installed with `winget install syncmlviewer`.
