#Replace Unit Name

$UNIT=ENRSRV*

Get-GPO -All | Where-Object {$_.displayname -like "$UNIT"} | Set-GPPermission -Replace -PermissionLevel GpoEditDeleteModifySecurity -TargetName "$UNIT-OUADMINS" -TargetType Group 



$GPO=Get-GPO -All | Where-Object {$_.displayname -like "ENRSRV*"} | Select DisplayName

$GPO | Set-GPPermission -Replace -PermissionLevel GpoEditDeleteModifySecurity -TargetName "ENRSRV-OUADMINS" -TargetType Group