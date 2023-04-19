Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 1
Write-Output "AD WUServer Enabled"
Restart-Service -Name wuauserv -Force
Write-Output "Service restarted"