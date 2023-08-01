param (
    [string]$Path # Path to the directory where files will be renamed
)

if ([string]::IsNullOrEmpty($Path)) { # Check if the path parameter is empty or null
    Write-Error "-Path "C:\Path\to\dir" is required" # Display an error message if the path parameter is empty or null
    exit 1 # Exit the script with an error code
}

$ErrorActionPreference = "Stop" # Set the error action preference to stop the script if an error occurs

Get-ChildItem -Path $Path -Include " *" -Recurse -Force | ForEach-Object { # Get all files in the specified directory and its subdirectories, including hidden files
    $filePath = $_.FullName # Get the full path of the file
    try { # Try to rename the file
        $_ | Rename-Item -NewName { $_.Name.TrimStart() } # Rename the file by removing any leading whitespace from its name
        Write-Output "Renaming file: $filePath to $($_.Name.TrimStart())" # Display a message indicating that the file has been renamed
    } catch { # Catch any errors that occur during the renaming process
        Write-Output "Error renaming file: $filePath" # Display an error message indicating that the file could not be renamed
    }
}