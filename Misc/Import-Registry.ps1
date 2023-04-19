<#
.SYNOPSIS
    To import registry (.reg) file using pure PowerShell.


.DESCRIPTION
Intended Use

    This script was produced to assist with importing registry (.reg) files where the registry
    handlers, such as reg.exe or regedit.exe, are blocked from executing. 


About
    
    This is a heavily modified version of the code snippet credit, many thanks to Xeнεi Ξэnвϵς for
    providing the heavy lifting.


Known Defects/Bugs
    
  * No known issues with correctly formed registry file. No error checking has been provided for a
    malformed registry file.

  * Large registry files do take time to import.


Code Snippet Credits
  * https://superuser.com/questions/1614623/how-to-convert-reg-files-to-powershell-set-itemproperty-commands-automatically


Version History 
    1.00 2020-03-09
    Initial release.


Copyright & Intellectual Property
    Feel to copy, modify and redistribute, but please pay credit where it is due.
    Feed back is welcome, please contact me on LinkedIn. 


.LINK
 Author:.......https://www.linkedin.com/in/rileylim
 Source Code:..https://gist.github.com/rileyz/52e721a609a9143158180f77b9f7ea0b


.EXAMPLE
    Import-Registry.ps1 [FileName.reg | PathToFileName.reg] [-ImportRecursively] [-WhatIf] 
        [-VerboseOutput] [-DebugOutput]


.EXAMPLE
    Import-Registry.ps1 FileName.reg

    Import a single registry file. When a absolute path is not provided, the script will check the
    $PSScriptRoot for the registry file.


.EXAMPLE
    Import-Registry.ps1 C:\Path\FileName.reg
    
    Import a single registry file with absolute path.


.EXAMPLE
    "C:\Path\FileName.reg","C:\AnotherPath\FileName.reg" | .\Import-Registry.ps1

    Pipeline regstry files to be imported to the script.


.EXAMPLE
    Import-Registry.ps1 -ImportRecursively -WhatIf -VerboseOutput -DebugOutput

    Recursively import registry files from the script root and subdirectories, with follow options.
    ImportRecursively: Recursively import registry files from the script root and subdirectories.
    WhatIf: Preforms WhatIf PowerShell action to evaluate changes.
    VerboseOutput: Displays verbose output.
    DebugOutput: Displays debug output.
#>



# Start of script work ############################################################################
[CmdLetBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)][string]$Path,
    [Parameter(ValueFromPipeline=$true)][switch]$ImportRecursively,
    [Parameter(ValueFromPipeline=$true)][switch]$WhatIf,
    [Parameter(ValueFromPipeline=$true)][switch]$VerboseOutput,
    [Parameter(ValueFromPipeline=$true)][switch]$DebugOutput
)

Begin {
    $hive = @{
        "HKEY_CLASSES_ROOT" = "HKCR:"
        "HKEY_CURRENT_USER" = "HKCU:"
        "HKEY_LOCAL_MACHINE" = "HKLM:"
        "HKEY_USERS" = "HKU:"
        "HKEY_CURRENT_CONFIG" = "HKCC:"
    }
    [system.boolean]$isfolder = $false
    $addedpath = @()
    if ($VerboseOutput) {
        $CurrentVerbosePreference = $VerbosePreference
        $VerbosePreference = 'Continue'
        Write-Verbose 'Verbose enabled.'
    }
    if ($DebugOutput) {
        $CurrentDebugPreference = $DebugPreference
        $DebugPreference = 'Continue'
        Write-Debug 'Debug enabled.'
    }
    if ($WhatIf) {
        Write-Warning 'WhatIf will throw errors if preformed on registry keys or subkey values which do not exist!'
    }
}

Process {
if ($Path -eq '') {
    Write-Verbose '$Path is null, setting $Past to $PSScriptRoot.'
    $Path = $PSScriptRoot
} elseif (Test-Path "$PSScriptRoot\$Path") {
    Write-Verbose '$Path was passed a file name only, converting to absolute path.'
    $Path = "$PSScriptRoot\$Path"
}
switch ($ImportRecursively)
    {
        $true {$Files = (Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object {$_.Extension -eq '.reg'}).FullName;$isfolder=$true}
        $false {if($Path.EndsWith(".reg")){$Files=$Path}}
    }
    foreach($File in $Files) {
        $Commands = @()
        [string]$text = $nul
        $FileContent = Get-Content $File | Where-Object {![string]::IsNullOrWhiteSpace($_)} | ForEach-Object { $_.Trim() }
        $joinedlines = @()
        for ($i = 0;$i -lt $FileContent.count;$i++){
            if ($FileContent[$i].EndsWith("\")) {
                $text = $text+($FileContent[$i] -replace "\\").trim()
            } else {
                $joinedlines += $text+$FileContent[$i]
                [string]$text = $nul
            }
        }
        Write-Debug "Contents of registry file: $((Get-ChildItem $File).Name) `r`n $($joinedlines | Out-String)"
        #Pause
        foreach ($joinedline in $joinedlines) {
            if ($joinedline -match '\[' -and $joinedline -match '\]' -and $joinedline -match 'HKEY') {
                $key = $joinedline -replace '\[|\]'
                Write-Debug "Processing registry key: $key"
                switch ($key.StartsWith("-HKEY"))
                {
                    $true {
                        $key = $key.substring(1,$key.length-1)
                        $hivename = $key.split('\')[0]
                        $key = "`"" + ($key -replace $hivename,$hive.$hivename) + "`""
                        Write-Debug " Registry key remove detected: $key"
                        if ($Whatif) {
                            $Commands += 'Remove-Item -Path {0} -Force -Recurse -WhatIf' -f $key
                        } else {
                            $Commands += 'Remove-Item -Path {0} -Force -Recurse' -f $key
                        }
                    }
                    $false {
                        $hivename = $key.split('\')[0]
                        $key = "`"" + ($key -replace $hivename,$hive.$hivename) + "`""
                        if ($addedpath -notcontains $key) {
                            Write-Debug " Registry key create/add detected: $key"
                            if ($Whatif) {
                                $Commands += 'New-Item -Path {0} -ErrorAction SilentlyContinue -WhatIf | Out-Null'-f $key   
                            } else {
                                $Commands += 'New-Item -Path {0} -ErrorAction SilentlyContinue | Out-Null'-f $key 
                            }
                            $addedpath += $key
                        } else {
                            Write-Debug " Previous command detected to create key, no need to do work."
                        }
                        #Pause
                    }
                }
            }
            elseif ($joinedline -match "`"([^`"=]+)`"=") {
                Write-Debug "Processing registry value: $(($joinedline) -replace '`r|`n')"
                [System.Boolean]$delete = $false
                $value =  $null
                $name = ($joinedline | Select-String -Pattern "`"([^`"=]+)`"").Matches.Value | Select-Object -First 1
                switch ($joinedline)
                {
                    {$joinedline -match "=-"} {
                        Write-Debug ' Registry value remove detected.'
                        if ($Whatif) {
                            $Commands += 'Remove-ItemProperty -Path {0} -Name {1} -Force -WhatIf' -f $key, $Name;$delete = $true
                        } else {
                            $Commands += 'Remove-ItemProperty -Path {0} -Name {1} -Force' -f $key, $Name;$delete = $true
                        }
                        #Pause 
                    }
                    {$joinedline -match '"="'} {
                        $type = "string"
                        $value = $joinedline -replace "`"([^`"=]+)`"="
                        $value = $value -replace '(\\\\)','\'
                    }
                    {$joinedline -match "dword"} {
                        $type = "dword"
                        $value = $joinedline -replace "`"([^`"=]+)`"=dword:"
                        $value = "0x"+$value
                    }
                    {$joinedline -match "qword"} {
                        $type = "qword"
                        $value = $joinedline -replace "`"([^`"=]+)`"=qword:"
                        $value = "0x"+$value
                    }
                    {$joinedline -match "hex(\([2,7,b]\))?:"} {
                        $value = ($joinedline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:").Split(",")
                        $hextype = ($joinedline | Select-String -Pattern "hex(\([2,7,b]\))?").Matches.Value
                        switch ($hextype)
                        {
                            'hex(2)' {
                                $value = for ($i = 0;$i -lt $value.count;$i += 2) {
                                    if ($value[$i] -ne '00') {[string][char][int]('0x'+$value[$i])}
                                }
                                $value = $value -join ""
                                $value = "'" + $value + "'"
                                $type = "expandstring"
                            }
                            'hex(7)' {
                                $value = for ($i = 0;$i -lt $value.count;$i += 2) {
                                    switch ($hextype)
                                    {
                                        'hex(2)' {if ($value[$i] -ne '00') {[string][char][int]('0x'+$value[$i])}}
                                        'hex(7)' {if ($value[$i] -ne '00') {[string][char][int]('0x'+$value[$i])} else {"\0"}}
                                    }
                                }
                                $value = $value -join ""
                                $value = $value.Replace('\0',',')
                                $value = $value.Substring(0,$value.Length-2)
                                $value = $value.Split(',') | foreach {"'" + $_ + "'"}
                                $value = ('@(' + ($value -join ",") + ')')
                                $type = "multistring"
                            }
                            'hex(b)' {
                                $type = "qword"
                                $value = for ($i = $value.count-1;$i -ge 0;$i--) {$value[$i]}
                                $value = '0x'+($value -join "").trimstart('0')
                            }
                            'hex' {
                                $type = "binary"
                                $buildbinaryvalue = $null
                                $value | foreach {$buildbinaryvalue += '0x' + $_ + ','}
                                $value = '(' + ($buildbinaryvalue.Substring(0,$buildbinaryvalue.Length-1)) + ')'                               
                            }
                        }
                    }
                }
                if ($delete -eq $false) {
                    Write-Debug " Registry value add/set detected, the registry type is '$type'."
                    if ($Whatif) {
                        $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3} -WhatIf' -f $key, $name, $type, $value
                    } else {
                        $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3}' -f $key, $name, $type, $value
                    }
                    #Pause
                }
            }
            elseif ($joinedline -match "@=") {
                Write-Debug "Processing registry value: $(($joinedline) -replace '`r|`n')"
                Write-Debug ' Registry value add/set detected.'
                $name = '"(Default)"';$type = 'string';$value = $joinedline -replace '@='
                if ($Whatif) {
                    $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3} -WhatIf' -f $key, $name, $type, $value
                } else {
                    $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3}' -f $key, $name, $type, $value
                }
                #Pause
            }
        }
        $parent = Split-Path $file -Parent
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $AllCommands += $Commands
    }
}

End {
        If ($VerboseOutput) {
            $AllCommands | foreach {
                Write-Verbose "Invoking $_"
                Invoke-Expression $_
            }
        } else {
            $AllCommands | foreach {Invoke-Expression $_}
        }
        if ($VerboseOutput) {
            Write-Verbose 'Verbose set back to orginal value.'
            $VerbosePreference = $CurrentVerbosePreference
        }
        if ($DebugOutput) {
            Write-Debug 'Debug set back to orginal value.'
            $DebugPreference = $CurrentDebugPreference
        }
}
#<<< End of script work >>>