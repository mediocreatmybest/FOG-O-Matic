 <#
.SYNOPSIS
    Enables Windows 10 Features based on a CSV, with the option to undo/remove.

.DESCRIPTION
    The CSV file should contain a header, then each feature name that needs to be enabled on a new line.
    Update the housekeeping section with required information.

    Example CSV contents below.
      Features
      NetFx4-AdvSrvs
      NetFx4Extended-ASPNET45


Code Snippet Credits
  * https://weblog.west-wind.com/posts/2017/May/25/Automating-IIS-Feature-Installation-with-Powershell
  * https://serverfault.com/questions/713187/powershell-install-windowsfeature-and-family-missing-on-windows-10
  * https://github.com/rileyz/VMR-Development/blob/master/Virtual%20Machine%20Runner/Framework/Module_Windows-Features-GlobalConfigure.ps1
  * https://gist.github.com/rileyz/464175e3bb96f1b67dfc


Version History
    1.01 06/11/2017
    Bug fix pram switch, and actually make the change.

    1.00 06/11/2017
    Initial release.


.LINK
Author:.......http://www.linkedin.com/in/rileylim
 Source Code:..https://gist.github.com/rileyz/eddcc798d1f306d1039d6a2ae01a0497
#>



Param ([Switch] $Undo)



# Function List ###################################################################################
Function LogWrite {Param ([String] $LogLine,
                          [Switch] $EndOfLog)
                   If ($EndOfLog -eq $True) {Add-content $LogFile -value 'INFO:   END OF LOGGING'
                                             Add-content $LogFile -value ''}
                                       Else {Add-content $LogFile -value $LogLine}}
#<<< End Of Function List >>>



# Setting up housekeeping #########################################################################
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FeaturesDescription = 'Windows 10 Enable'
$FeaturesConfigurationFile = 'List_of_Features.csv'
$LogDate = Get-Date -Format 'dd MMMM, yyyy, HH:mm.'
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$VerbosePreference = 'SilentlyContinue' #SilentlyContinue|Continue

If ($Undo -eq $true)
    {$Mode = 'Disable'}
Else{$Mode = 'Enable'}

$LogFile = "$env:systemroot\Temp\$((Get-ChildItem "$ScriptPath\$FeaturesConfigurationFile").BaseName)" + '.txt'

LogWrite 'INFO:   ****************************************'
LogWrite "INFO:   $FeaturesDescription"
LogWrite 'INFO:   Author: http://www.linkedin.com/in/rileylim'
LogWrite 'INFO:   Source Script: https://gist.github.com/rileyz/eddcc798d1f306d1039d6a2ae01a0497'
LogWrite "INFO:   $LogDate"
LogWrite "INFO:   Features Configuration File: $FeaturesConfigurationFile"
LogWrite "INFO:   Features Mode: $Mode"
LogWrite 'INFO:   ****************************************'

$FeaturesToEnable = Import-Csv "$ScriptPath\$FeaturesConfigurationFile"

$ArrayScriptExitResult = @()

If ($Mode -eq 'Enable')
    {#Enable Features in CSV.
     ForEach ($_ in $FeaturesToEnable)
         {Write-Verbose "Working on feature '$($_.Features)'"
          LogWrite "INFO:   Working on feature '$($_.Features)'"
          $WorkingOnCurrentFeature = $_.Features

          If ((Get-WindowsOptionalFeature -Online | where {$_.FeatureName -eq "$WorkingOnCurrentFeature"}).State -ne 'Enabled')
             {Write-Verbose ' Feature is disabled, will enabled.'
              LogWrite 'INFO:   Feature is disabled, will enabled.'
              $FeatureObject = Enable-WindowsOptionalFeature -Online -FeatureName $WorkingOnCurrentFeature -NoRestart
              If ($? -eq $true)
                  {Write-Verbose 'Feature was enabled OK.'
                   LogWrite 'INFO:   Feature was enabled OK.'
                   $ArrayScriptExitResult += '0'
                   If ($FeatureObject.RestartNeeded -eq $true)
                       {$ArrayScriptExitResult += '3010'}}
              Else{Write-Warning 'Error in enabling feature.'
                   LogWrite 'ERROR:  Error in enabling feature.'
                   $ArrayScriptExitResult += 1}}
         Else{Write-Verbose ' Feature already enabled!'
              LogWrite 'INFO:   Feature already enabled!'}}}

Else{#Disable Features in CSV.
     ForEach ($_ in $FeaturesToEnable)
         {Write-Verbose "Working on feature '$($_.Features)'"
          LogWrite "INFO:   Working on feature '$($_.Features)'"
          $WorkingOnCurrentFeature = $_.Features

          If ((Get-WindowsOptionalFeature -Online | where {$_.FeatureName -eq "$WorkingOnCurrentFeature"}).State -ne 'Disabled')
             {Write-Verbose ' Feature is enabled, will disabled.'
              LogWrite 'INFO:   Feature is enabled, will disabled.'
              $FeatureObject = Disable-WindowsOptionalFeature -Online -FeatureName $WorkingOnCurrentFeature -NoRestart
              If ($? -eq $true)
                  {Write-Verbose 'Feature was disabled OK.'
                   LogWrite 'INFO:   Feature was disabled OK.'
                   $ArrayScriptExitResult += '0'
                   If ($FeatureObject.RestartNeeded -eq $true)
                       {$ArrayScriptExitResult += '3010'}}
              Else{Write-Warning 'Error in disabling feature.'
                   LogWrite 'ERROR:  Error in disabling feature.'
                   $ArrayScriptExitResult += 1}}
         Else{Write-Verbose ' Feature already disabled!'
              LogWrite 'INFO:   Feature already disabled!'}}}

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this variable

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'}

Switch ($ScriptExitResult)
    {'0'        {LogWrite 'INFO:   Processing of file complete. Return Result: 0.'
                 LogWrite -EndOfLog
                 Return '0'}
     'Reboot'   {LogWrite 'INFO:   Processing of file complete. Return Result: 3010.'
                 LogWrite -EndOfLog
                 Return '3010'}
     'Error'    {LogWrite 'INFO:   Processing of file complete. Return Result: 1.'
                 LogWrite -EndOfLog
                 Return 'Error'}
     Default    {LogWrite 'Error:  Default/Null return on switch statement!'
                 LogWrite -EndOfLog
                 Return 'Null'}}
#<<< End of script work >>>
