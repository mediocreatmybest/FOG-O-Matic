# ID 30 matches to BitLocker key being reset/updated
Get-WinEvent Microsoft-Windows-MBAM/Operational |Select-Object TimeCreated, Id, LevelDisplayName, Message | Where-Object { $_.Id -match "30" } |Format-Table -wrap