Get-ADDomainController -Filter * `
   | Select Name, IsGlobalCatalog, Site, IPV4Address, `
     @{N='SchemaMaster';E={'SchemaMaster' -in $_.OperationMasterRoles}}, `
     @{N='DomainNamingMaster';E={'DomainNamingMaster' -in $_.OperationMasterRoles}}, `
     @{N='PDCEmulator';E={'PDCEmulator' -in $_.OperationMasterRoles}}, `
     @{N='RIDMaster';E={'RIDMaster' -in $_.OperationMasterRoles}}, `
     @{N='InfrastructureMaster';E={'InfrastructureMaster' -in $_.OperationMasterRoles}} `
   | FT -AutoSize