param (
    [string]$Path
)

if ([string]::IsNullOrEmpty($Path)) {
    Write-Error "-Path "C:\Path\to\dir" is required"
    exit 1
}

$ErrorActionPreference = "Stop"

Get-ChildItem -Path $Path -Include " *" -Recurse -Force | ForEach-Object {
    $filePath = $_.FullName
    try {
        $_ | Rename-Item -NewName { $_.Name.TrimStart() }
        Write-Output "Renaming file: $filePath to $($_.Name.TrimStart())"
    } catch {
        Write-Output "Error renaming file: $filePath"
    }
}