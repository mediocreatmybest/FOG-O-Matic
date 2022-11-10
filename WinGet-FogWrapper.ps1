#Fog PowerShell wrapper for WinGet snapin
#Available options in Winget -mode -opt1 -op2 etc.
param ($opt1, $opt2, $opt3, $mode, $source, $package)


#Config
#Find the directory for Winget due to folder changes, why does this need to be changed?!
$fullwingetloc = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include WinGet.exe -Recurse | Select -ExpandProperty FullName
$sourceagreement = '--accept-source-agreements'
$packageagreement = '--accept-package-agreements'
$silent = '--silent'
#Config End

#If nothing is entered for the arguments
if ($mode -eq $null){ 
echo ""
echo "e.g. Usage -mode install or -mode upgrade" |Out-File -Append c:\fog.log
echo "e.g. Usage -opt1 -opt2 -op3 etc are passed on to winget as avilable Winget options" |Out-File -Append c:\fog.log
exit 
}

if ($source -eq $null){ 
echo "" |Out-File -Append c:\fog.log
echo "Did you select a source?" |Out-File -Append c:\fog.log
exit 
}

#install Mode Commands

if ($mode -eq 'install'){ 
echo "Install Mode ACTIVATE!"
echo "Command used was: $fullwingetloc $mode $package $opt1 $opt2 $opt3 -s $source $silent $packageagreement $sourceagreement" |Out-File -Append c:\fog.log
& $fullwingetloc $mode $package $opt1 $opt2 $opt3 '-s' $source $silent $packageagreement $sourceagreement |Out-File -Append c:\fog.log
exit 
}

# Upgrade Commands

if ($mode -eq 'upgrade'){ 
echo "Upgrade Mode ACTIVATE!" 
echo "Command used was: $fullwingetloc $mode $opt1 $opt2 $opt3 -s $source $silent $sourceagreement" |Out-File -Append c:\fog.log
& $fullwingetloc $mode $opt1 $opt2 $opt3 '-s' $source $silent $sourceagreement |Out-File -Append c:\fog.log
exit 
}

# Catch all other options

echo "" |Out-File -Append c:\fog.log
echo "end of script, did you use install or upgrade? am I broken? do I only exist to pass butter?" |Out-File -Append c:\fog.log
exit
