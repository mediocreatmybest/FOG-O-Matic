#Fog PowerShell wrapper for WinGet snapin

#Find the directory for Winget due to folder changes, why does this need to be changed?!

$fullwingetloc = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include WinGet.exe -Recurse | Select -ExpandProperty FullName
& "$fullwingetloc" install CodecGuide.K-LiteCodecPack.Full -s winget --silent