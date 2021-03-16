# Remove Microsoft OneDrive Client Script
# Author: Simon Lee
# Date  : January 2019
# Version 0.5

# Stop OneDrive Process and Uninstall
taskkill /f /im OneDrive.exe
& "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall

# Take Ownsership of OneDriveSetup.exe
$ACL = Get-ACL -Path $env:SystemRoot\SysWOW64\OneDriveSetup.exe
$Group = New-Object System.Security.Principal.NTAccount("$env:UserName")
$ACL.SetOwner($Group)
Set-Acl -Path $env:SystemRoot\SysWOW64\OneDriveSetup.exe -AclObject $ACL

# Assign Full R/W Permissions to $env:UserName (Administrator)
$Acl = Get-Acl "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$env:UserName","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" $Acl

# Take Ownsership of OneDriveSettingSyncProvider.dll
$ACL = Get-ACL -Path $env:SystemRoot\SysWOW64\OneDriveSettingSyncProvider.dll
$Group = New-Object System.Security.Principal.NTAccount("$env:UserName")
$ACL.SetOwner($Group)
Set-Acl -Path $env:SystemRoot\SysWOW64\OneDriveSettingSyncProvider.dll -AclObject $ACL

# Assign Full R/W Permissions to $env:UserName (Administrator)
$Acl = Get-Acl "$env:SystemRoot\SysWOW64\OneDriveSettingSyncProvider.dll"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$env:UserName","FullControl","Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$env:SystemRoot\SysWOW64\OneDriveSettingSyncProvider.dll" $Acl

# Take Ownsership of OneDrive.ico
$ACL = Get-ACL -Path $env:SystemRoot\SysWOW64\OneDrive.ico
$Group = New-Object System.Security.Principal.NTAccount("$env:UserName")
$ACL.SetOwner($Group)
Set-Acl -Path $env:SystemRoot\SysWOW64\OneDrive.ico -AclObject $ACL