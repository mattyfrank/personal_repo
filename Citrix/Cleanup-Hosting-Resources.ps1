Add-PsSnapin Citrix.Host.Admin.V2

Add-PsSnapin Citrix.MachineCreation.Admin.V2

cd xdhyp:

cd .\HostingUnits\

Get-ChildItem | select PSChildName, HostingUnitUid

$HostingUnitID='18ebe7f2-77fe-4add-bb3c-397306434b20'
Get-ProvTask | Where-Object { $_.ImagesToDelete | Where-Object { $_.HostingUnit -eq $HostingUnitID } }


Get-ProvTask | Where-Object { $_.ImagesToDelete | Where-Object { $_.HostingUnit -eq $HostingUnitID } } | select TaskId

Get-ProvTask | Where-Object { $_.ImagesToDelete | Where-Object { $_.HostingUnit -eq $HostingUnitID } } | Remove-ProvTask


Remove-ProvTask -TaskID 

#Storage : 
#Remove-HypHostingUnitStorage -LiteralPath XDHyp:\HostingUnits\MyHostingUnit -StoragePath 'XDHyp:\HostingUnits\MyHostingUnits\newStorage.storage'

#PersonalvDiskStorage:
#Get-ChildItem XDHyp:\HostingUnits\MyHostingUnit\*.storage | Remove-HypHostingUnitStorage -LiteralPath XDHyp:\HostingUnits\MyHostingUnit -StorageType PersonalvDiskStorage

#TemporaryStorage:
#Get-ChildItem XDHyp:\HostingUnits\MyHostingUnit\*.storage | Remove-HypHostingUnitStorage -LiteralPath XDHyp:\HostingUnits\MyHostingUnit -StorageType TemporaryStorage


#Hosting Resource Name
Remove-Item -path XDHyp:\HostingUnits\NonGPU-VLAN1272-Old