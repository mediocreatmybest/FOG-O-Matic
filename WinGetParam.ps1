#Fog PowerShell wrapper for WinGet snapin

#Find the directory for Winget due to folder changes, why does this need to be changed?!
param ($wingetcmd, $wingetopt1, $wingetopt2, $wingetopt3, $wingetopt4)

$fullwingetloc = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include WinGet.exe -Recurse | Select -ExpandProperty FullName
& "$fullwingetloc" $wingetcmd $wingetopt1 $wingetopt2 $wingetopt3 $wingetopt4