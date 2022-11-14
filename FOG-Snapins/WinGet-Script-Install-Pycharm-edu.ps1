#Fog PowerShell Script Snapin for WinGet

#Find the directory for Winget due to folder changes, why does this need to be changed?!

$fullwingetloc = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include WinGet.exe -Recurse | Select -ExpandProperty FullName
& "$fullwingetloc" install JetBrains.PyCharm.Community -s winget --silent
