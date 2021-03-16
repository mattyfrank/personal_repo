#Get ADGroupMember Properties.
Import-Module ActiveDirectory

Get-ADGroupMember -Identity "Group_Name" | Get-ADCOMPUTER -Properties CanonicalName | Select Name, CanonicalName | Export-Csv –NoType c:\export\ADComputerMember.csv

Get-ADGroupMember -Identity "Group_Name" -Recursive | Get-ADUSER -Properties CanonicalName | Select Name, CanonicalName | Export-Csv –NoType c:\export\ADUserMember.csv