param (
    [Parameter(Mandatory = $false)]
    [string]$ComputerName
)

if ($ComputerName -eq $null -or $ComputerName -eq "") {
    Write-Host "Please select the computer name with -ComputerName"
    exit
}

# Download module from https://www.microsoft.com/en-us/download/details.aspx?id=46899
$LAPSPWD = Get-AdmPwdPassword -ComputerName $ComputerName | Select-Object ComputerName, Password
Write-Output "ComputerName: $($LAPSPWD.ComputerName) LAPS AdmPwd: $($LAPSPWD.Password)"