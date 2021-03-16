# find_acct_not_in_GTED.ps1 
# Script to find GTAD accounts not in GTED - scoped by OU

# Usage:  .\find_acct_not_in_GTED <OU to search (full LDAP format)> 
#         .\find_acct_not_in_GTED "OU=test,DC=ad,DC=gatech,DC=edu" 

Param ($OU)  

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

Get-ADUser -Filter * -Properties * -searchbase $OU | Where-Object {$_.memberof -notcontains 'cn=_gt_member,OU=Affiliations-Internal,OU=Gted,OU=GT_Resources,DC=ad,DC=gatech,DC=edu'}  | ft name, CanonicalName

