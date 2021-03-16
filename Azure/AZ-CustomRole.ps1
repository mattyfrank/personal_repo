Login-AzAccount

$ResourceGroup = Get-AzResourceGroup -Name 'WVD-HostGroup-General'
#ResourceId: /subscriptions/c1835977-39e7-4415-a092-a77866f5afb8/resourceGroups/WVD-HostGroup-General

$role = Get-AzRoleDefinition "WVD - User Session Contributor"
#Name: WVD - User Session Contributor
#Id: 9618385d-7c4c-4cf3-a62b-9a299d19e94a

$user = Get-AzADUser -UserPrincipalName jhoward308@gatech.edu
#Id: fea10d78-af44-4dd9-9370-9d02d81d9feb

#Example of Ad-Hoc Assign User - Custom Role - to Resource Group
New-AzRoleAssignment -SignInName "jhoward308@gatech.edu" -RoleDefinitionName "WVD - User Session Contributor" -ResourceGroupName "WVD-HostGroup-General"

#Add in Variables
New-AzRoleAssignment -ObjectId $($user.Id) -RoleDefinitionName $($role.Name) -ResourceGroupName $($ResourceGroup.ResourceGroupName)

#Get-AZGroup
Get-AzADGroup -DisplayName "cloud-esd-all-staff-list"

#Get AZ Ad Group Members
Get-AzADGroupMember -GroupDisplayName "cloud-esd-all-staff-list" | select userprincipalname

#Get AD GroupMembers
Get-ADGroupMember "ESD-ALL" -recursive 

#Scratch testing extensions. 
# $ADGroupMember = Get-ADGroupMember "ESD-ALL" -recursive | Get-ADUser -Properties UserPrincipalName
# $ADGroupMember.userprincipalname



#Add Members of AZ AD Group to AZ Custom Role
$AzGroup = Get-AzADGroupMember -GroupDisplayName "cloud-esd-all-staff-list"
$ResourceGroup = Get-AzResourceGroup -Name 'WVD-HostGroup-General'
foreach ($account in $AzGroup) {
Write-Host "Adding $($account.UserPrincipalName)"

New-AzRoleAssignment -ObjectId $($account.Id) -RoleDefinitionName $($role.Name) -ResourceGroupName $($ResourceGroup.ResourceGroupName)

}




#Get Members of AD Group - Select UPN - Add to AZ Custom Role
$ADGroupMember = Get-ADGroupMember "ESD-ALL" -recursive | Get-ADUser -Properties UserPrincipalName
$ResourceGroup = Get-AzResourceGroup -Name 'WVD-HostGroup-General'
foreach ($account in $ADGroupMember) {
Write-Host "Adding $($account.UserPrincipalName)"

New-AzRoleAssignment -ObjectId $($account.Id) -RoleDefinitionName $($role.Name) -ResourceGroupName $($ResourceGroup.ResourceGroupName)

}