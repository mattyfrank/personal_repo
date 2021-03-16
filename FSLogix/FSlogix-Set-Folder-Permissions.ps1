 #Set FSlogix Folder Permission 
<#
 Security permissions: 
-Admins - Full 
-SYSTEM - Full 
-CREATOR OWNER - Full - Subdirs/files only 
-Auth Users - Modify - This folder only 
#>

#Set folder to set permissions.
$Folder = "\\azntap-54b4\fslogix-eastus\TestDestination"

#Create Folder 
#New-Item -Path "$Folder\Sub-Folder" -ItemType Directory

#Set Delegated Administrators
#$Administrators = "AD\XEN-OUADMINS"

#Disable Folder Inheritance
Write-Output "Remove Inheritance"
icacls "$Folder" /inheritance:d


#reset acl to inherited permissions
icacls "$Folder" /reset

#Remove Permission for Everyone
Write-Output "Remove Everyone"
icacls $Folder /remove 'NT Authority\Everyone' /t /c

Write-Output "Set Permissions on User Profiles"
$objACL = Get-ACL -Path $Folder
$objACL.SetAccessRuleProtection($True, $False)

$FullRights = [System.Security.AccessControl.FileSystemRights]::FullControl
$ModifyRights = [System.Security.AccessControl.FileSystemRights]::Modify
$InheritanceYes = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit","ObjectInherit"
$InheritanceNo = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$objType =[System.Security.AccessControl.AccessControlType]::Allow 

$objUser = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.SetAccessRule($objACE) 

#Delegated Administrators
#$objUser = New-Object System.Security.Principal.NTAccount("$Administrators") 
#$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
#$objACL.AddAccessRule($objACE) 

$objUser = New-Object System.Security.Principal.NTAccount("AD\XEN-OUADMINS") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE)

$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$objUser = New-Object System.Security.Principal.NTAccount("CREATOR OWNER") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

$objUser = New-Object System.Security.Principal.NTAccount("NT Authority\Authenticated Users") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $ModifyRights, $InheritanceNo, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

(Get-Item $Folder).SetAccessControl($objACL)
