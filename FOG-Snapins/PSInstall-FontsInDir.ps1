param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FontPath
)

# Check if the font path exists
if (-not (Test-Path $FontPath)) {
    Write-Error "The specified font path does not exist: $FontPath"
    Exit 1
}

# Install fonts
$SystemFontPath = "$($env:SystemRoot)\Fonts"
$Fonts = Get-ChildItem -Path $FontPath -Include *.otf,*.ttf,*.ttc -Recurse -File
foreach ($Font in $Fonts) {
    # Unblock the font file, we totally trust it right?!
    Write-Output "Running Unblock-File PowerShell command on $($Font.FullName)"
    Unblock-File $Font.FullName

    # Copy the font file to the system font folder
    $Destination = Join-Path $SystemFontPath $Font.Name
    Copy-Item $Font.FullName -Destination $Destination -Force

    # Register the font in the registry
    $Type = $Font.Extension.TrimStart('.')
    $Name = $Font.Name.Split('.')[0]
    $FontKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\"
    $FontValue = "$($Font.Name)"

    if ($Type -eq "ttf") {
        $TypeName = "(TrueType)"
    } elseif ($Type -eq "otf") {
        $TypeName = "(OpenType)"
    } elseif ($Type -eq "ttc") {
        $TypeName = "(TrueTypeCollection)"
    }
    $regName = "$Name $TypeName"
    Write-Output "Inserting $regName as Font Name with a value of $FontValue"
    New-ItemProperty -Path $FontKey -Name $regName -Value $FontValue -Force | Out-Null
}

Write-Output "If you didn't get an error the fonts should be installed successfully, err. maybe reboot and check."