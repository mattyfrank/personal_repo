

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colServerInfo = objWMIService.ExecQuery _
	("Select * from Win32_ComputerSystem")
For Each objserverinfo in colServerInfo
	
 	StrComputerName = objserverinfo.name
	
 Next

strdate=date()
strdate= strdate-1
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("updates.csv")

Set objSession = CreateObject("Microsoft.Update.Session")
Set objSearcher = objSession.CreateUpdateSearcher
intHistoryCount = objSearcher.GetTotalHistoryCount

Set colHistory = objSearcher.QueryHistory(1, intHistoryCount)

objfile.writeline StrComputerName


For Each objEntry in colHistory
    'objfile.writeline "Operation: " & objEntry.Operation
    'objfile.writeline "Result code: " & objEntry.ResultCode
    'objfile.writeline "Exception: " & objEntry.Exception
 If cdate(objEntry.Date) > cdate(strdate) then     
    'objfile.writeline "Date: " & objEntry.Date
    objfile.writeline "- " & objEntry.Title
    'objfile.writeline "Description: " & objEntry.Description
    'objfile.writeline "Unmapped exception: " & objEntry.UnmappedException
    'objfile.writeline "Client application ID: " & objEntry.ClientApplicationID
    'objfile.writeline "Server selection: " & objEntry.ServerSelection
    'objfile.writeline "Service ID: " & objEntry.ServiceID
    i = 1
    For Each strStep in objEntry.UninstallationSteps
        objfile.writeline i & " -- " & strStep
        i = i + 1
    Next
    'objfile.writeline "Uninstallation notes: " & objEntry.UninstallationNotes
    'objfile.writeline "Support URL: " & objEntry.SupportURL
    'objfile.writeline
 else

 end if
Next

msgbox("done")