# Import the Active Directory module
Import-Module ActiveDirectory

# Set the path to the CSV file and the target OU
# CVS has Name column
$csvPath = "C:\misc\computers.csv"
$targetOU = "OU=xyz,OU=Computers,OU=zyx,OU=zxy,DC=zxc,DC=com"

# Import data from the CSV file
$computers = Import-Csv -Path $csvPath

# Move computers into the target OU
foreach ($computer in $computers) {

    # Get the computer's distinguished name
    $computerName = (Get-ADComputer $computer.Name).Name
    $computerDN = (Get-ADComputer $computer.Name).DistinguishedName
    Write-Output "Moving $computerName, DN is: $computerDN --> $targetOU"
    # Move the computer into the target OU
    Move-ADObject -Identity $computerDN -TargetPath $targetOU
}