# List_OUs_with Blocked_Security_inheritance.ps1
# get a list OUs that have blocked inheritance on their security permissions

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

#$BaseOU = Get-ADOrganizationalUnit -Filter * -Properties * -SearchScope OneLevel
#ForEach ($member in $BaseOU) {

$OUs = Get-ADOrganizationalUnit -Filter * | sort canonicalname |Select-Object -Property DistinguishedName
#$OUs = Get-ADOrganizationalUnit -Filter * | Select-Object -Property DistinguishedName
#$OUs = Get-ADOrganizationalUnit -Filter * -searchbase $member -SearchScope OneLevel | Select-Object -Property DistinguishedName
$SecurityAllUsers = $OUs | ForEach-Object {



    get-acl "ad:$($_.distinguishedname)" 


    }
$Security = $SecurityAllUsers | Where-Object {$_.AreAccessRulesProtected}
#$Security = $SecurityAllUsers 
$security = $Security | Sort-Object -Property PSpath
$Security |select -Property AreAccessRulesProtected, psChildname, PSparentpath   | export-csv C:\batchlib\Report_of_OUs_with_blocked_Security_inheritance.csv -append 

#}

