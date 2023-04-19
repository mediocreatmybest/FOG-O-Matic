$BLV = Get-BitLockerVolume
write-output $BLV
Clear-BitLockerAutoUnlock
Disable-BitLocker -MountPoint $BLV