# List_OUs_with Blocked_GPO_inheritance.ps1
# get a list OUs that have blocked inheritance on their GPOs

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

# imports GroupPolicy module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module GroupPolicy)){            
  Import-Module GroupPolicy         
}

# Set file and path and clear any old file that exists
# ----------------------------------------------
$File="C:\batchlib\OUs_with_blocked_inheritance.txt"
If (Test-Path $File) {
 Remove-Item $File
}

# Get list of OUs and write to file
# ----------------------------------------------
Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | Select-Object path | export-csv $File -append

# Get list of OUs from file above and do lookups
# ----------------------------------------------
(Get-Content $File) | Foreach-Object {$_ -replace "`"", ""} | Set-Content $File
$arymembers = Get-Content C:\batchlib\OUs_with_blocked_inheritance.txt
Foreach ($Path in $arymembers)
{
#write-host $Path
Get-ADObject $Path -Properties * | Select-Object Name, CanonicalName, DistinguishedName, whenChanged | export-csv C:\batchlib\Report_of_OUs_with_blocked_inheritance.csv -append
}

