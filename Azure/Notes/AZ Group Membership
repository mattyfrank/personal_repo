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

#Ad-Hoc AD User as a Member or Azure AD Group.
$ADUserID = "rgriffin47"
$UserObjectID = Get-AzureADUser -searchstring $ADUserID 
Add-AzureADGroupMember -ObjectId $TargetGroupObjectID -RefObjectId $UserObjectID.ObjectID

#Confirm User Membership of TargetGroup
$ADmember|  select UserPrincipalName |measure
$AZGroupMembers | select UserPrincipalName | measure
Get-AzureADGroupMember -objectid $TargetGroupObjectID | measure
Get-AzureADGroupMember -objectid $TargetGroupObjectID | select UserPrincipalName

