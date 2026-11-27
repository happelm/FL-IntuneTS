# CmtraceRemove.ps1 - uninstall command of the Win32 app flaneX-CMTrace (Intune-TS Exercise 5.1)
# Removes CMTrace.exe from C:\Windows and the open command of the .log file type.
# Based on the CMTrace association script by Jorgen Nilsson (CCMexec.com).

Remove-Item "$($env:windir)\CMTrace.exe" -Force 
Remove-Item -LiteralPath 'HKLM:\Software\Classes\Log.File\shell\open\command' -Force -ErrorAction SilentlyContinue

