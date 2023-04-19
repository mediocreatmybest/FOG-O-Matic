Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 0
Write-Output "AD WUServer disabled"
Restart-Service -Name wuauserv -Force
Write-Output "Service restarted"