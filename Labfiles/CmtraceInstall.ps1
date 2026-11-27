# CmtraceInstall.ps1 - install command of the Win32 app flaneX-CMTrace (Intune-TS Exercise 5.1)
# Copies CMTrace.exe to C:\Windows and registers it as the default viewer for .log and .lo_ files.
# Based on the CMTrace association script by Jorgen Nilsson (CCMexec.com).

# Copy CMTrace.exe (the detection file) and create the file type keys
Copy-Item "$($PSScriptRoot)\CMTrace.exe" -Destination "$($env:windir)\CMTrace.exe" -Force
New-Item -Path 'HKLM:\Software\Classes\.lo_' -type Directory -Force -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Classes\.log' -type Directory -Force -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Classes\.log.File' -type Directory -Force -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Classes\.Log.File\shell' -type Directory -Force -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Classes\Log.File\shell\Open' -type Directory -Force -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Classes\Log.File\shell\Open\Command' -type Directory -Force -ErrorAction SilentlyContinue

# Point .log and .lo_ to CMTrace
New-ItemProperty -LiteralPath 'HKLM:\Software\Classes\.lo_' -Name '(default)' -Value "Log.File" -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Classes\.log' -Name '(default)' -Value "Log.File" -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\Software\Classes\Log.File\shell\open\command' -Name '(default)' -Value "`"C:\Windows\CMTrace.exe`" `"%1`"" -PropertyType String -Force -ea SilentlyContinue;

