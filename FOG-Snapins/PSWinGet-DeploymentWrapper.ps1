<#
.SYNOPSIS
PowerShell wrapper script for installing, uninstalling, or upgrading applications using Winget via deployment such as FOG Project.

.DESCRIPTION
This allows you to use Winget via a PowerShell script to install, uninstall,
or upgrade applications when you can't push a powershell command on its own and need a script.

.PARAMETER Action
Specifies the action to perform. The available options are: Install, Uninstall, or Upgrade.

.PARAMETER Package
Specifies the package name to be installed, uninstalled, or upgraded.

.PARAMETER LogFile
Specifies the path and filename for the log file.

.PARAMETER WingetSource
Specifies the source to be used by Winget. e.g winget or msstore

.PARAMETER UsePath
Specifies if you want to force the use of PATH, otherwise it searches by default in:
'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*'
I don't think this is needed but left for the giggles

.EXAMPLE
FOG Example - This script could also be packaged as an EXE for easier use
.\PSWinGet-DeploymentWrapper.ps1 -Action Install -Package "Greenshot.Greenshot" -WingetSource "winget" -LogFile "C:\fog.log"
Installs Greenshot from the community source 'winget' and logs the output to the specified log file.

.EXAMPLE
.\PSWinGet-DeploymentWrapper.ps1 -Action Uninstall -Package "Greenshot.Greenshot"
Uninstalls Visual Studio Code using the default system-wide installation of Winget.

# All Parameters are non mandatory to prevent locking up deployment while waiting for a prompt that never comes. Such is life.
# TODO: create a cleanup section, add in a section that can be customised to delete files and folders etc.

#>


param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Upgrade')]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$Package,

    [Parameter(Mandatory = $false)]
    [string]$WingetSource,

    [Parameter(Mandatory = $false)]
    [string]$LogFile,

    [Parameter(Mandatory = $false)]
    [switch]$UsePath

)

# Find WinGet.exe as it likes to move based on version numbers. Making this so much easier to script. Thanks.
$WinGetLocation = Get-Childitem -Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*' -Include winget.exe -Recurse | Select-Object -ExpandProperty FullName

# Set additionals
# We could add this as params but since this is for deployment, I don't think it is needed.
# Feel free to change and pull request! or not.
$AgreementSource = '--accept-source-agreements'
$AgreementPackage = '--accept-package-agreements'
$Silent = '--silent'
$DisableInteractivity = '--disable-interactivity'
$PadLogStart = "
------------------------------------------------------------------------------`
---------------------------------WinGet Output--------------------------------`
------------------------------------------------------------------------------`
$(Get-Date) `nSelected package: $Package `nwith action: $Action`n"
$PadLogEnd = "`n------------------------------------------------------------------------------"


if (!$Action -or !$Package) {
    Write-Host "Usage: PSWinGet-DeploymentWrapper.ps1 -Action [Install|Uninstall|Upgrade] -Package [PackageName] [-WingetSource [WingetSource]] [-LogFile [LogFile]]"
    return
}

# Use Path otherwise use found version of winget.exe
if ($UsePath) {
    $wingetPath = 'winget.exe'
    #write-output "using $wingetPath"
} else {
    $wingetPath = $WinGetLocation
    #write-output "using $wingetPath"
}

# Default to community source
if ($WingetSource) {
    $WingetSource = $WingetSource
} else {
    $WingetSource = "winget"
}

switch ($Action) {
    "Install" {
        Write-Verbose "Installing $Package using Winget from $wingetPath..."
        if ($LogFile) {
$PadLogStart | Out-File -FilePath $LogFile -Append -Encoding utf8
& $wingetPath install $Package $AgreementPackage $AgreementSource $Silent $DisableInteractivity --source $WingetSource 2>&1 | Out-File -FilePath $LogFile -Append -Encoding utf8
$PadLogEnd | Out-File -FilePath $LogFile -Append -Encoding utf8
        } else {
& $wingetPath install $Package $AgreementPackage $AgreementSource $Silent $DisableInteractivity --source $WingetSource
        }
    }
    "Uninstall" {
        Write-Verbose "Uninstalling $Package using Winget from $wingetPath..."
        if ($LogFile) {
$PadLogStart | Out-File -FilePath $LogFile -Append -Encoding utf8
& $wingetPath uninstall $Package $Silent $DisableInteractivity --source $WingetSource 2>&1 | Out-File -FilePath $LogFile -Append -Encoding utf8
$PadLogEnd | Out-File -FilePath $LogFile -Append -Encoding utf8
        } else {
& $wingetPath uninstall $Package $Silent $DisableInteractivity --source $WingetSource
        }
    }
    "Upgrade" {
        Write-Verbose "Upgrading $Package using Winget from $wingetPath..."
        if ($LogFile) {
$PadLogStart | Out-File -FilePath $LogFile -Append -Encoding utf8
& $wingetPath upgrade $Package $Silent $DisableInteractivity --source $WingetSource 2>&1 | Out-File -FilePath $LogFile -Append -Encoding utf8
$PadLogEnd | Out-File -FilePath $LogFile -Append -Encoding utf8
        } else {
& $wingetPath upgrade $Package $Silent $DisableInteractivity --source $WingetSource
        }
    }
}