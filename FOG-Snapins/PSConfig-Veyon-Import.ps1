#Clears and Imports up to date rooms from ADGroup
$groups = Get-ADGroup -SearchBase "OU=Groups,OU=xyz,OU=xyz,DC=xyzplace,DC=net" -Filter {Name -like "ComputerGroup*"}
$groupfull = @()

foreach($group in $groups){
    $groupresult = Get-ADGroupMember $group
        foreach($result in $groupresult){
        $obj = New-Object -TypeName System.Object
        $obj | Add-Member -Type NoteProperty -Name Room -value $group.Name
        $obj | Add-Member -Type NoteProperty -Name Name -value $result.Name
        $obj | Add-Member -Type NoteProperty -Name Host -value (($result.Name)+".xyzplace.net")
        $groupfull += $obj
    }
}

# Exports the information out to csv files
$groupfull | ConvertTo-Csv -NoTypeInformation | select -skip 1 |% { $_ -replace '"', ""}|Set-Content $PSScriptRoot\computers-with-rooms.csv |out-null

& 'C:\Program Files\Veyon\veyon-cli.exe' networkobjects clear|out-null
& 'C:\Program Files\Veyon\veyon-cli.exe' networkobjects import $PSScriptRoot\computers-with-rooms.csv format %location%,%name%,%host%