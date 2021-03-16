(Get-WinEvent -ListLog *).logname | ForEach-Object {[System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog(“$psitem”)}

Wevtutil el | ForEach { wevtutil cl “$_”}