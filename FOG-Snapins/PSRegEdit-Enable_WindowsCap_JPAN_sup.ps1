Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 0
Restart-Service -Name wuauserv -Force
Get-WindowsCapability -Name Language.Fonts.Jpan~~~und-JPAN~0.0.1.0 -Online | Add-WindowsCapability -Online
Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 1
Restart-Service -Name wuauserv -Force