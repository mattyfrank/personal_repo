# find_group_members_not_in_GTED.ps1  
# Script to find GTAD accounts not in GTED - scoped by group 
 
#  Usage:  .\find_acct_not_in_GTED <group>  
#         .\find_acct_not_in_GTED "TEST_group"  

Param ([Parameter(Mandatory=$true)][string]$Group) 
  
# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

Get-ADGroupMember $Group -Recursive | Get-ADUser -Properties * | Where-Object {$_.memberof -notcontains 'cn=_gt_member,OU=Affiliations-Internal,OU=Gted,OU=GT_Resources,DC=ad,DC=gatech,DC=edu'}  | ft name, samaccountname, CanonicalName
