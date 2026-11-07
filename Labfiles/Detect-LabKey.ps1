# Lab 6.1 - detection script of the remediation studentX-Reg
# Replace flaneX with your user name (for example flane3) before you upload the script.
# Exit 1 = issue found (key missing) -> Intune runs the remediation script.

$Key = 'HKLM:\SOFTWARE\flaneX\Lab'

if (Test-Path -Path $Key) {
    Write-Output "Key $Key exists"
    exit 0
}

Write-Output "Key $Key missing"
exit 1
