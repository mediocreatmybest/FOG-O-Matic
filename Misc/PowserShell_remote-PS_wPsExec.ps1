$scriptBlock = {
    # Script goes here
    $fqdn = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
    write-output "Computer name: $fqdn"
    # End of script
    }

$rmtcomputer = $args[0]
if ([string]::IsNullOrWhiteSpace($rmtcomputer)) {
    do {
        $rmtcomputer = Read-Host "Please Enter a remote computer name"
    } until (![string]::IsNullOrWhiteSpace($rmtcomputer))
}

# Encode to Base64String to make this easier to execute
# Use PsExec to run the command -s for system if needed, add to PATH or set full directory path
# Download from https://learn.microsoft.com/en-us/sysinternals/
$encodedScriptBlock = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))
$psexecOutput = PsExec.exe \\$rmtcomputer -accepteula -nobanner powershell.exe -encodedCommand $encodedScriptBlock
# Need a better way to supress XML
Clear-Host
Write-Output " "
Write-Output " "
Write-Output "##########################################################"
Write-Output "#                   Remote Command Output                #"
Write-Output "##########################################################"
Write-Output " "
Write-Output $psexecOutput
Write-Output " "
Write-Output "##########################################################"
Write-Output "#                End of Remote Command Output            #"
Write-Output "##########################################################"
Write-Output " "
Write-Output " "