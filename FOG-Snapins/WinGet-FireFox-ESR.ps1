#Fog PowerShell Script Snapin for WinGet

#Config
#Find the directory for Winget due to folder changes, why does this need to be changed?!
$fullwingetloc = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include WinGet.exe -Recurse | Select -ExpandProperty FullName
$sourceagreement = '--accept-source-agreements'
$packageagreement = '--accept-package-agreements'
$silent = '--silent'
#Config End

& "$fullwingetloc" install Mozilla.Firefox.ESR -s winget $silent $packageagreement $sourceagreement |Out-File -Append c:\fog.log