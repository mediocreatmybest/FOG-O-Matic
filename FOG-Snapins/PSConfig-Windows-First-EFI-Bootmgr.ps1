#Set Windows to be the first in EFI bootmgr
#
#Please See - https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcd-system-store-settings-for-uefi?view=windows-11#other-settings
#
c:\windows\system32\bcdedit.exe /set “{fwbootmgr}” displayorder “{bootmgr}” /addfirst