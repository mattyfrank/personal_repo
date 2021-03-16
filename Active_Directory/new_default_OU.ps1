# new_default_OU.ps1
# script to create new default OU
# Usage: .\new_default_OU.ps1 <newOU name to be created> "Where the new ou should be created in LDAP format>" 
#        .\new_default_OU.ps1 temptestou "OU=_oit,DC=ad,DC=gatech,DC=edu" 

Param (
    [Parameter(Mandatory=$true)][string]$NewOU,
    [Parameter(Mandatory=$true)][string] $OUrootPath
)

if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

$OUName = '_' + $NewOU
#$OUName = $NewOU
$OUPath = "ou="+ $OUName + "," + $OUrootPath
$Poupath = "ou=People," + $OUpath
$Groupath = "ou=Groups," + $OUpath
$deptOUADMINS = $NewOU + "-ouadmins"
$deptOUUsers  = $NewOU + "-ouusers"

# Check to see if ou exists
# ----------------------------------------------
Write-Host "    "
try {            
    if([ADSI]::Exists("LDAP://$OuPath")) {            
        Write-Host "Given OU exists try again"; exit        
    } else {            
        Write-Host "Good, OU Not found so it can be created"            
    }            
} catch {            
    Write-Host "Error Occurred while querying for the OU"            
}  


Write-Host 'Going to create new OU '$OUName' under' $OUrootPath
Write-Host "  "

Write-Host "    "
Write-Host 'OU will be called ' $OUName
Write-Host 'OU path is ' $OUPath 
Write-Host 'The people OU will be placed at ' $Poupath
Write-Host 'The groups OU will be placed at ' $Groupath 
Write-Host "    "


#creating OU Structure
#-----------------------------------
NEW-ADOrganizationalUnit $OUName –path $OUrootPath -server gtad01
NEW-ADOrganizationalUnit  "Department Accounts" –path $OUPath -server gtad01
NEW-ADOrganizationalUnit  "Groups" –path $OUPath -server gtad01
NEW-ADOrganizationalUnit  "People" –path $OUPath -server gtad01
NEW-ADOrganizationalUnit  "Resources" –path $OUPath -server gtad01
NEW-ADOrganizationalUnit  "Servers" –path $OUPath -server gtad01
NEW-ADOrganizationalUnit  "Workstations" –path $OUPath -server gtad01

NEW-ADOrganizationalUnit  "Office365" –path $Groupath -server gtad01

NEW-ADOrganizationalUnit  "Employees" -path $Poupath -server gtad01
NEW-ADOrganizationalUnit  "Guest" -path $Poupath -server gtad01
NEW-ADOrganizationalUnit  "Other" -path $Poupath -server gtad01
NEW-ADOrganizationalUnit  "Students" -path $Poupath -server gtad01


#creating groups
#-----------------------------------
Write-Host "going to create groups called $deptOUADMINS  and  $deptOUADMINS "
Write-Host "  "
New-ADGroup -Name $deptOUADMINS -SamAccountName $deptOUADMINS -GroupCategory Security -GroupScope Global -Path $Groupath -server gtad01
New-ADGroup -Name $deptOUUsers -SamAccountName $deptOUUsers -GroupCategory Security -GroupScope Global -Path $Groupath -server gtad01



