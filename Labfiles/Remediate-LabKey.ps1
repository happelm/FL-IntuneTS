# Lab 6.1 - remediation script of the remediation studentX-Reg
# Replace studentX with your prefix (for example student3) before you upload the script.

$Key = 'HKLM:\SOFTWARE\studentX\Lab'

try {
    New-Item -Path $Key -Force -ErrorAction Stop | Out-Null
    Write-Output "Key $Key created"
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
