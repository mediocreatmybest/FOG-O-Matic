param ($configtype,$master)

#Config
#2020 - Installer for Veyon
#Notes: This is written to be used within a zip fog deployment package with required files
$veyoninstaller = "veyon-4.7.4.0-win64-setup.exe"
$staffconfig = "Staff.json"
$studentconfig = "Students.json"
$directoryPath = "C:\xyz\Certs"
#Config End

if ($configtype -eq 'student'){ $config = $studentconfig }
if ($configtype -eq 'staff'){ $config = $staffconfig }
if ($master -eq 'no'){ $setmaster = " /NoMaster" }
if ($master -eq 'yes'){ $setmaster = $null }
if ($configtype -eq $null){ 
echo "e.g. Usage -configtype student or staff" 
echo "e.g. Usage -master yes or no"
exit 
}

#Create certs folder if it doesn't exist.
if(!(Test-Path -path $directoryPath))  
{  
    New-Item -ItemType directory -Path $directoryPath              
}
else
{
Write-Host "Directory exists, nothing to do here..";
}

#Using Certs in Veyon, copy cert if it doesn't exist from the fog zip package
Copy-Item $PSScriptRoot"\Cert.pem" -Destination "c:\xyz\Certs\" -Recurse -Force| out-null
Start-Process -FilePath "$PSScriptRoot\$veyoninstaller" -Wait -ArgumentList "/S$setmaster /ApplyConfig=$PSScriptRoot\$config"| out-null
if ($configtype -eq 'student'){ Remove-Item –path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veyon" –recurse -force| out-null }