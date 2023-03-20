$DaysInactive = 90

$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -SearchBase "OU=Computers, OU=xyz, OU=xyz, DC=xyz, DC=com" -Filter {LastLogonTimeStamp -lt $time -and name -like "LT-*"} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName
