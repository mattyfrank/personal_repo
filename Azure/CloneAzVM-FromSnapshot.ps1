##Create Image from AZ VM Snapshot

#Connect to Azure
Connect-AzAccount

#Define the source VM
$vmName = "NV4v4-Win10"
$ResourceGroupName = "OIT-VLAB-SCENTRAL"
$location = "southcentralus"
$SnapshotName = "NV4v4-Win10-Snap1"

#$VM will display the source VM
$vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroupName

#$disk will display the disk properties
$disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name

#Create Snapshot Configuration
$snapshotConfig =  New-AzSnapshotConfig -SourceUri $disk.Id -OsType Windows -CreateOption Copy -Location $location

#Create snapshot
$snapShot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

#$snapShot will display the snapshot properties

##Ready to make Template##

#locate SubnetID
$vnetResourceGroup = 'OIT-Vlab-SCentral'
$vnetName = 'OIT-Vlab-SCentral'
$subnetName = 'default'
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $vnetResourceGroup
$subnetID = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

#Create ResourceGroup for the Tempalte (easier cleanup)
$templateVMResourceGroupName = 'NV4v4-Template'
$location = "southcentralus" 
New-AzResourceGroup -Name $templateVMResourceGroupName -Location $location

#Create OS Disk 
$osDiskName = 'NV4v4-Template-OsDisk'
$osDisk = New-AzDisk -DiskName $osDiskName -Disk (New-AzDiskConfig  -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id) -ResourceGroupName $templateVMResourceGroupName

$osDisk

#Create vNIC 
$nicName = 'NV4v4-Template-Nic01'
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $templateVMResourceGroupName -Location $location -SubnetId $subnetID.Id 

#Set the Vm Name and Size
$templateVMName = 'NV4v-Template'
$vmConfig = New-AzVMConfig -VMName $templateVMName -VMSize 'Standard_NV4as_v4'

#Add the newly created network to the vm
$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

#Add the OS Disk 
$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -StorageAccountType Standard_LRS -DiskSizeInGB 128 -CreateOption Attach -Windows


#Create Templace Vm
New-AzVM -ResourceGroupName $templateVMResourceGroupName -Location $location -VM $vm

