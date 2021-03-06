#################WVD Notes - Mfranklin7#################
########################################################

#############################################
#Setup Workstation & Install/Update Modules#
############################################
Set-ExecutionPolicy Unrestricted

Install-Module -Name Microsoft.RDInfra.RDPowerShell
Update-Module -Name Microsoft.RDInfra.RDPowerShell
Import-Module -Name Microsoft.RDInfra.RDPowerShell

Install-Module AzureAD
Update-Module -Name AzureAD
Import-Module AzureAD

Install-Module -Name Az -AllowClobber
Install-Module -Name Az -AllowClobber -Force

####################################
###Connect to Azure, WVD, and AAD###
####################################

Connect-AzAccount
#az-mfranklin7@gatech.edu

Connect-AzureAD
#az-mfranklin7@gatech.edu

Add-RdsAccount –DeploymentUrl “https://rdbroker.wvd.microsoft.com”
#az-mfranklin7@gatech.edu

###################################
###Setup Environmental Variables###
###################################

$AADGUID="482198bb-ae7b-4b25-8b7a-6d7f32faa083"
$SubGUID="c1835977-39e7-4415-a092-a77866f5afb8"
$WVDTenantName = "GT-WVD"
$HostPoolName = "Remote Workspace"
$AppGroupName ="Desktop Application Group"

#Create WVD Tenant#
#New-RdsTenant -Name $WVDTenantName -AadTenantId $AADGUID -AzureSubscriptionId $SubGUID

#Tenant Details
Get-RdsTenant $WVDTenantName

#Assign additional user Tenant Owner for RDS. 
New-RdsRoleAssignment -TenantName $WVDTenantName -RoleDefinitionName "RDS Owner" -UserPrincipalName user@gatech.edu
New-RdsRoleAssignment -TenantName $WVDTenantName -RoleDefinitionName "RDS Owner" -ApplicationId 5aa05e66-7acc-40ef-9dd1-84b65bc001ae

#List all HostPools
Get-RdsHostPool -TenantName $WVDTenantName
Get-RdsHostPool -TenantName $WVDTenantName | select HostPoolName

#List Servers in HostPool
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName | Where-Object AllowNewSession -eq $true #$false

#List App Group
Get-RdsAppGroup -TenantName $WVDTenantName -HostPoolName $HostPoolName
Get-RdsAppGroup -TenantName $WVDTenantName -HostPoolName $HostPoolName | select AppGroupName

#List Desktop Name
Get-RdsRemoteDesktop $WVDTenantName $HostPoolName $AppGroupName | select FriendlyName



#######################################################################################
##########Add AD Users from Azure AD SourceGroup to Azure AD TargetGroup###############
#######################################################################################

#Use AZ Object ID when there are multiple names that match searchstring
$SourceADGroup= "_tableau-oit-all_tableau_oit_departmental_gt"
$SourceAADGroup= "VLab Admins"
$SourceGroupObjectID ="8b3a8586-4ae2-497b-8986-6348a3b413d5"
$TargetAADGroup= "WVD-Users"
$TargetGroupObjectID= "d24b1643-b607-41d6-9668-a2bc87930219"

#When refrencing traditional AD - Convert AD Group Members to AZ Users and Add to AAD Group. 
$ADmember= Get-ADGroupMember -Recursive $SourceADGroup | Get-ADUser
$AZUserObjectID = ForEach ($member in $ADmember){Get-AZureADUser -searchstring $member.SamAccountName}
ForEach ($id in $AZUserObjectID.ObjectID) { Add-AzureADGroupMember -ObjectId $TargetGroupObjectID -RefObjectId $id
}

#For Each Member of Azure SourceGroup add to Azure TargetGroup
$AZGroupMembers = Get-AzureADGroupMember -objectid $SourceGroupObjectID 
ForEach ($member in $AZGroupMembers.ObjectID) {
Add-AzureADGroupMember -ObjectId $TargetGroupObjectID -RefObjectId $member
}

#Confirm User Membership of TargetGroup
$ADmember|  select UserPrincipalName |measure
$AZGroupMembers | select UserPrincipalName | measure
Get-AzureADGroupMember -objectid $TargetGroupObjectID | measure
Get-AzureADGroupMember -objectid $TargetGroupObjectID | select UserPrincipalName


##################################################################
#####Add/Remove Users to access WVD Desktop/Application Group#####
##################################################################

#Add a user to an Application Group:
Add-RdsAppGroupUser -TenantName $WVDTenantName -HostPoolName $HostPoolName $AppGroupName -UserPrincipalName user@gatech.edu

#Remove a user from an Application Group: 
Remove-RdsAppGroupUser -TenantName $WVDTenantName -HostPoolName $HostPoolName $AppGroupName -UserPrincipalName user@gatech.edu

#Confirm who has access to WVD
$WVDUsers=Get-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName | export-csv c:\WVD-USERS.CSV
echo "Current users authorized for $AppGroupName are:"
echo $WVDUsers.UserPrincipalName

#Get Traditional AD Group Members | Select UPN | Add to WVD Tenant
#May result in UPN not in AzureAD#
$ADmember= Get-ADGroupMember -Recursive 'oit-all' | Get-ADUser | select UserPrincipalName
Echo "The following users will be ADDED to AppGroup $AppGroupName :"
ECHO $ADmember

ForEach ($u in $ADmember){
echo "Adding $ADmember to $AppGroupName"
Add-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName -UserPrincipalName $u
}

############################################################
#############TEST SYNC######################################
############################################################
$AADGroup = Get-AzureADGroup -SearchString "WVD-Users"
$AADGroupObjectID = "d24b1643-b607-41d6-9668-a2bc87930219"
$AADusers =  Get-AzureADGroupMember -objectid $AADGroup.ObjectId | Sort-Object | Get-Unique
$WVDUsers=Get-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName


#Remove members in the list from WVD HostPoolMembers if user NOT in AD User List
foreach ($member in $WVDUsers)
{
   if ($aadUsers.UserPrincipalName -notcontains $member.UserPrincipalName)
   {
      Write-Output ("Removing " + $member.UserPrincipalName)
      Remove-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName -UserPrincipalName $member.UserPrincipalName
   }
}

#Add Members in the AD User List that are NOT members of the WVD HostPool
foreach ($user in $aadUsers.UserPrincipalName)
{
   if ($hostPoolMembers.UserPrincipalName -notcontains $user)
   {
      Write-Output ("Adding " + $User)
      Add-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName -UserPrincipalName $user
   }
}


#Confirm who has access to WVD
$WVDUsers=Get-RdsAppGroupUser $WVDTenantName $HostPoolName $AppGroupName
echo "Current users authorized for $AppGroupName are:"
echo $WVDUsers.UserPrincipalName



#####################################################################
###Add/Remove Members of AAD Group as Users to WVD Desktop Group ####
#####################################################################
$GroupName= "WVD-Users"
$GroupObjectID= "d24b1643-b607-41d6-9668-a2bc87930219"
$Action="Add"

$GroupObjectID=Get-AzADGroup -Searchstring $GroupName | select ID
$GroupMembers= Get-AzureADGroupMember -objectid $GroupObjectID -All 1

If ($Action -eq "add") {
Echo "The following users will be ADDED to AppGroup $AppGroupName :"
ECHO $GroupMembers.UserPrincipalName
ForEach ($member in $GroupMembers.UserPrincipalName) {
echo "Adding $member to $AppGroupName"
Add-RdsAppGroupUser -TenantName $WVDTenantName -HostPoolName $HostPoolName -AppGroupName $AppGroupName -UserPrincipalName $member}
$RDSAppGroupUsersList=get-rdsappgroupuser -TenantName $WVDtenantname -HostPoolName $hostpoolname -AppGroupName $AppGroupName
echo "Current users authorized for $AppGroupName are:"
echo $RDSAppGroupUsersList.UserPrincipalName
}

#Confirm resource membership.
Get-RdsAppGroupUser -TenantName $WVDTenantName -HostPoolName $HostPoolName -AppGroupName $AppGroupName | Export-Csv c:\WVD-Users.csv

#How to Remove a Group
$GroupName= "WVD-Users"
$GroupObjectID= "d24b1643-b607-41d6-9668-a2bc87930219"
$Action="remove"

If ($Action -eq "remove") {
Echo "The following users will be REMOVED from AppGroup $AppGroupName :"
ECHO $GroupMembers.UserPrincipalName
ForEach ($member in $GroupMembers.UserPrincipalName) {
echo "Removing $member from $AppGroupName"
Remove-RdsAppGroupUser -TenantName $WVDTenantName -HostPoolName $HostPoolName -AppGroupName $AppGroupName -UserPrincipalName $member}
$RDSAppGroupUsersList=get-rdsappgroupuser -TenantName $WVDtenantname -HostPoolName $hostpoolname -AppGroupName $AppGroupName
echo "Current users authorized for $AppGroupName are:"
echo $RDSAppGroupUsersList.UserPrincipalName
}

##########################################################################
#####Maintenance for HostPools, SessionHosts, AppGroups, UserSessions#####
##########################################################################

#Modify the Host Pool breadth-first
Set-RdsHostPool -TenantName $WVDTenantName -HostPoolName $HostPoolName -BreadthFirstLoadBalancer

#Modify the Host Pool depth-first, set Max Session Limit
Set-RdsHostPool -TenantName $WVDTenantName -Name $HostPoolName -DepthFirstLoadBalancer

#Enable Drain Mode on all Hosts
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName | Set-RdsSessionHost -AllowNewSession $false -ErrorAction SilentlyContinue
#Set all Hosts that are in Drain Mode to Enabled
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName | Where-Object AllowNewSession -eq $false | Set-RdsSessionHost -AllowNewSession $true -ErrorAction SilentlyContinue
#Set specific Host to Drain or Enabled
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName -Name "WVD-Gen-0.ad.gatech.edu" | Set-RdsSessionHost -AllowNewSession $true  
Get-RdsSessionHost -TenantName $WVDTenantName -HostPoolName $HostPoolName -Name "WVD-Gen-1.ad.gatech.edu" | Set-RdsSessionHost -AllowNewSession $true 

#Get All User Sessions
Get-RdsUserSession -TenantName $WVDTenantName -HostPoolName $HostPoolName

#Disconnect-User Session(s)
Disconnect-RdsUserSession $WVDTenantName $HostPoolName -SessionHostName "WVD-Gen-1.ad.gatech.edu" -SessionId 1
Get-RdsUserSession $WVDTenantName $HostPoolName | Disconnect-RdsUserSession -NoUserPrompt
Get-RdsUserSession $WVDTenantName $HostPoolName | where SessionState -eq "Disconnected" | Disconnect-RdsUserSession -NoUserPrompt
Get-RdsUserSession $WVDTenantName $HostPoolName | where { $_.UserPrincipalName -eq "ad\username" } | Disconnect-RdsUserSession -NoUserPrompt

#Logoff User Session(s)
Invoke-RdsUserSessionLogoff $WVDTenantName $HostPoolName -SessionHostName "WVD-Gen-0.ad.gatech.edu" -SessionId 1
Get-RdsUserSession $WVDTenantName $HostPoolName | where SessionState -eq "Disconnected" | Invoke-RdsUserSessionLogoff -NoUserPrompt 

#Force VM(s) to reboot.
$ResourceGroupName = "WVD-HostGroup-General"
Get-AzVM -ResourceGroupName $ResourceGroupName | where name -eq wvd-gen-2 | Restart-AzVM

#REBOOTS All VMs in ResourceGroup - 
#Get-AzVM -ResourceGroupName $ResourceGroupName | Restart-AzVM

#Delete App Group
Get-RdsAppGroup -TenantName $WVDTenantName -HostPoolName $HostPoolName | Remove-RdsAppGroup

#Delete a Session Host
Remove-RDsSessionHost -force -TenantName $WVDTenantName -HostPoolName $HostPoolName 

#Delete Host Pool
Get-RdsHostPool -TenantName $WVDTenantName -HostPoolName $HostPoolName | Remove-RdsHostPool


<#
Refrences:
https://github.com/DeanCefola/Azure-WVD

https://github.com/DeanCefola/Azure-WVD/blob/master/PowerShell/WVD-Scaling-Automation.ps1

https://github.com/Azure/RDS-Templates/tree/master/wvd-templates

https://github.com/Azure/RDS-Templates/blob/master/wvd-sh/WVD%20scaling%20script/Azure%20WVD%20Auto-Scaling-v1.docx

#>

