# createtestfolder.ps1 - platform script flaneX-Folder (Intune-TS Exercise 6.1)
# Creates C:\TestFolder once; the output lands in AgentExecutor.log.
$folderPath = "C:\TestFolder"

# Only act when the folder is missing
if (-not (Test-Path -Path $folderPath)) {
    # First run: create it
    New-Item -Path $folderPath -ItemType Directory
    Write-Output "Folder created at $folderPath"
} else {
    Write-Output "Folder already exists at $folderPath"
}
