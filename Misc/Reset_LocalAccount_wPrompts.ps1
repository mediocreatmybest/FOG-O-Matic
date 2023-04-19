Write-Host "###################################"
Write-Host "        Reset Local Account        "
Write-Host "                                   "
Write-Host "###################################"
Write-Host " "
$localaccount = Read-Host -Prompt "Enter Local Account name"
$password = Read-Host -Prompt "Enter Temp Password"
$admin = Get-LocalUser -Name $localaccount
$admin | Set-LocalUser -Password(ConvertTo-SecureString -AsPlainText $password -Force)
Write-Host " "
write-output "$($admin) password should now be reset."