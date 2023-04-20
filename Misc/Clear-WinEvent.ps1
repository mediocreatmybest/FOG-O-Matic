Function Global:Clear-WinEvent ($Logname) {
#Clear-WinEvent -Logname Application

[System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog("$Logname")

}