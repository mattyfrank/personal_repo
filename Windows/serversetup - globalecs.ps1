import-module servermanager
add-windowsfeature backup-tools
add-computer -domainname ad.gatech.edu -oupath "ou=global ecs,ou=servers,ou=_oit,dc=ad,dc=gatech,dc=edu" -cred ad\adsgirard3 -passthru
net localgroup administrators ad\oit-sla-admins /add
net localgroup administrators ad\eis-ouadmins /add


