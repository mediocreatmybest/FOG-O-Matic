param (
   [Parameter(Mandatory=$true)]
   [string]$AppxPath,

   [Parameter(Mandatory=$false)]
   [string]$DependencyFolderName,

   [Parameter(Mandatory=$false)]
   [int]$UseFullPath = 0
)

# If the dependency folder name was flagged, use it
if ($DependencyFolderName) {
   if ($UseFullPath -eq 1) {
      # Use the dependency folder and files as a full path if flagged for it
      $DependencyFolder = $DependencyFolderName
   } else {
      # Get the script's folder path and set our location, might not need this but oh well.
      $ScriptFolder = $PSScriptRoot
      Set-Location $ScriptFolder
      # Get the dependency folder path (Can break if dependency folder is given as a full path or soemthing else)
      # Maybe put check for it in future
      $DependencyFolder = Join-Path -Path $ScriptFolder -ChildPath $DependencyFolderName
   }

   # Get dependency files in the folder with Get-ChildItem
   $DependencyFiles = Get-ChildItem -Path $DependencyFolder -File | Select-Object -ExpandProperty FullName

   # Install the appx package with the dependency paths for all users / Err Switched to Add-ProvisionedAppxPackage to flag -Online with all users
   # Why have a different params for another cmdlet ugh.
   Add-ProvisionedAppxPackage -PackagePath $AppxPath -DependencyPackagePath $DependencyFiles -SkipLicense -Online
} else {
   # If no dependency folder name was provided, just try install the appx package by itself for all users
   # Seems to work on systems I've tested but I suspect not all will have the required deps.
   Add-ProvisionedAppxPackage -PackagePath $AppxPath -SkipLicense -Online
}