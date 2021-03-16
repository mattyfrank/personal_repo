#Convert Local Profile to FSLogix Roaming Profile
#C:\Program Files\FSLogix\Apps\frx.exe 


#UserName to convert profile
$USERNAME = Get-ADUser gburdell

#Set Delegated Administrators
#$Administrators = "AD\XEN-OUADMINS"

#FSLogix Network Share Location
$Path = "\\azntap-54b4.ad.gatech.edu\fslogix-eastus\WVD-NAME\$($USERNAME.SamAccountName)_$($UserName.sid)"
#$Path = "C:\temp\$($USERNAME.SamAccountName)_$($UserName.sid)"

#Local User Profile Path
$LocalUserPath = "C:\Users\$($USERNAME.SamAccountName)"

#Create User Profile Directory
Write-Host "Creating User Profile Location: " $Path
New-Item $Path -ItemType Directory

#Setup ACL Permissions for User Folder
$FullRights = [System.Security.AccessControl.FileSystemRights]::FullControl
$ModifyRights = [System.Security.AccessControl.FileSystemRights]::Modify
$InheritanceYes = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit","ObjectInherit"
$InheritanceNo = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$objType =[System.Security.AccessControl.AccessControlType]::Allow 

Write-Output "Set Permissions for: " $path

#Reset Permissions to inhertance
icacls $path /reset

#Disable Folder Inheritance
Write-Output "Remove Inheritance $path"
icacls $path /inheritance:d

Write-Output "Reset Inheritance $path"
icacls $path /reset


#Remove Permission for Everyone
Write-Output "Remove Everyone from $path"
icacls $path /remove 'NT Authority\Everyone' /t /c

#Get source ACL from LocalProfile
$objACL = Get-ACL -Path $path
$objACL.SetAccessRuleProtection($True, $False)

#SYSTEM - Full 
$objUser = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.SetAccessRule($objACE) 

#set full control permission for user object
$objUser = New-Object System.Security.Principal.NTAccount("ad.gatech.edu", $($USERNAME.SamAccountName))
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

#Delegated Admins
$objUser = New-Object System.Security.Principal.NTAccount("$Administrators") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

#Site Admins
$objUser = New-Object System.Security.Principal.NTAccount("AD\XEN-OUADMINS") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE)

$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$objUser = New-Object System.Security.Principal.NTAccount("CREATOR OWNER") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

(Get-Item $Path).SetAccessControl($objACL)

#Create VHDX Container
Write-Host "Creating Profile Container: " $Path\Profile_$($USERNAME.SamAccountName).vhdx
Start-Process -FilePath "C:\Program Files\FSLogix\Apps\frx.exe" -Argumentlist "create-vhd -filename $Path\Profile_$($USERNAME.SamAccountName).vhdx"
Start-Sleep -Seconds 180

#Copy Profile
Write-Host "Copy Local Profile to FSlogix Romaining Profile." 
Start-Process -FilePath "C:\Program Files\FSLogix\Apps\frx.exe" -Argumentlist "copy-profile -filename $Path\Profile_$($USERNAME.SamAccountName).vhdx -username ad\$($USERNAME.SamAccountName)"

Start-Sleep -Seconds 260
#Start-Process -FilePath "C:\Program Files\FSLogix\Apps\frx.exe" -Argumentlist "copy-profile -filename $Path\Profile_$($USERNAME.SamAccountName).vhdx -username ad\$($USERNAME.SamAccountName)"


<#
SCRATCH... 

#Temp Directory.
#"%temp%\FrxMount"

#Delete temp Mount
#remove-item $env:Temp\FrxMount\* -recurse 
#Remove-Item $env:Windir\Temp\FrxMount\* -Recurse

#>