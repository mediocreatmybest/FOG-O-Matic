[CmdletBinding()]
param (
    [switch]$ResetNetwork,
    [switch]$RefreshNetwork
)

if ($ResetNetwork) {
    Write-Output "Resetting network..."
    netsh winsock reset
    netsh int ip reset
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    Write-Output "Network reset complete."
}

if ($RefreshNetwork) {
    Write-Output "Refreshing network..."
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    Write-Output "Network refresh complete."
}