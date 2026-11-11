# Set-KeyboardUS.ps1 - Fast Lane Remote Labs: English (US) keyboard on CL1/CL2
# Run once in an elevated PowerShell. Sets English (US) for the current user,
# the welcome screen and system accounts, new users, and (via Startup) every user at sign-in.
# Welcome screen and system accounts change after a restart.

Set-WinUserLanguageList en-US -Force
Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
Set-Content -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\KeyboardUS.cmd" -Value '@powershell -NoProfile -WindowStyle Hidden -Command "Set-WinUserLanguageList en-US -Force"'
Restart-Computer -Confirm
