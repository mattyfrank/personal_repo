#Copy GroupMembership 

Get-ADUser -Identity 'SourceUserAccount' -Properties memberof |
Select-Object -ExpandProperty memberof |
Add-ADGroupMember -Members 'DestinationUserAccount'

