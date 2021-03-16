#Copy FSLogix Directories to two new locations.
#Set Permissions for new location.


#Set the SourcePath as a parent directory of fslogix folders.
$SourcePath = Get-Item "\\azntap-54b4.ad.gatech.edu\fslogix-eastus\TestSource"
$profiles = Get-ChildItem "$SourcePath"
$OfficePath = Get-Item "\\azntap-54b4.ad.gatech.edu\fslogix-eastus\WVD-General-Office" | ?{ $_.PSIsContainer }
$ProfilePath = Get-Item "\\azntap-54b4.ad.gatech.edu\fslogix-eastus\WVD-General-Profile" | ?{ $_.PSIsContainer }



foreach ($profile in $profiles) 
{
    Write-Host "Copying Profile: "$SourcePath\$profile
    
    #copy profile directory and container to profile directory
    Write-Host "to New Profile Location: "$ProfilePath\$profile
    Robocopy $SourcePath\$profile $ProfilePath\$profile "Profile*" /mir /sec /secfix /v

    #copy profile directory and container to office directory
    Write-Host "to New Office Location: "$OfficePath\$profile
    Robocopy $SourcePath\$profile $OfficePath\$profile "ODFC*" /mir /sec /secfix /v

    
    $FullRights = [System.Security.AccessControl.FileSystemRights]::FullControl
    $ModifyRights = [System.Security.AccessControl.FileSystemRights]::Modify
    $InheritanceYes = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit","ObjectInherit"
    $InheritanceNo = [System.Security.AccessControl.InheritanceFlags]::None
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
    $objType =[System.Security.AccessControl.AccessControlType]::Allow 


    #set variable for source folder ACLs
    $ACL = (get-item  $SourcePath).GetAccessControl('Access')
    #$ACL = (get-item  $sourcefolder).GetAccessControl('Owner') ##Owner Not Allowed

    #set variable for username based on folder name
    $username = $profile.name.split("_")[0]   
    
    #set variable for user object
    $objUser = New-Object System.Security.Principal.NTAccount("ad.gatech.edu", "$username")
    
    #set variable for access control
    $AccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType)
    
    #set variable for ACL rule above
    $ACL.AddAccessRule($AccessRule1)
    #$ACL.SetOwner($objUser) ##!Owner is not allowed

    #set the above access to two destination folders
    Set-Acl -path $ProfilePath\$profile $ACL
    Set-Acl -path $OfficePath\$profile $ACL


    }

##Scratch##
 #get ACL from source "$profile\subdir"
 #$origAcl = Get-Acl -Path $sourcefolder

 #set ACL like above
 #Get-Acl -Path $sourcefolder | Set-Acl -Path $destprofilefolder -AclObject $origAcl
 #Set-Acl -Path $destprofilefolder -AclObject $origAcl
 #Set-Acl -Path $destofficefolder -AclObject $origAcl
  