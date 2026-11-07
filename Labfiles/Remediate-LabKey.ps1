# Lab 6.1 - remediation script of the remediation studentX-Reg
# Replace flaneX with your user name (for example flane3) before you upload the script.

$Key = 'HKLM:\SOFTWARE\flaneX\Lab'

try {
    New-Item -Path $Key -Force -ErrorAction Stop | Out-Null
    Write-Output "Key $Key created"
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
