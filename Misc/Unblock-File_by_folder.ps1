# Function to unblock all files in a directory
function Unblock-Files {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    # Get everything
    $files = Get-ChildItem -Path $Path -Recurse
    foreach ($file in $files) {
        # Unblock the file
        Unblock-File -Path $file.FullName
    }
}

# Prompt for directory
$directoryPath = Read-Host -Prompt 'Input the path of the directory'

# Unblock everything, we totally trust that this is extra safe? right Anakin? Anakin...
Unblock-Files -Path $directoryPath