#Load Citrix module 
asnp Citrix*

#Get-VMs, Last Logged in Users from specific Delivery Group
Get-BrokerDesktop -DesktopGroupName "Ece-Staff" -MaxRecordCount 1000 -DesktopKind Private | sort HostedMachineName | Select-Object -Property HostedMachineName,HypervisorConnectionName,LastConnectionUser |Export-Csv c:\users\matthew\desktop\Ece-Staff-Export.csv

#Get-VMs, Last Logged in User from specific Machine Catalog
Get-BrokerDesktop -Filter {CatalogName -eq 'ECE-Staff'} | sort HostedMachineName | Select-Object -Property HostedMachineName,HypervisorConnectionName,LastConnectionUser |Export-Csv c:\users\matthew\desktop\Ece-Staff-Export.csv

#Place VMs into Maintenance Mode and Gracefully Shutdown.

#Turn on maintenance mode
$machines = Get-BrokerMachine -MachineName AD\ECE-Staff-*
#$machines = Get-Content c:\users\matthew\test.tx
foreach ($machine in $machines){
Write-host (date -Format hh:mm:ss)   -   Placing $machine into maintenance mode 
Set-BrokerMachineMaintenanceMode -InputObject AD\$machine $true
# Stopping target VM
Write-host (date -Format hh:mm:ss)   -   Shutting down $machine -Verbose
New-BrokerHostingPowerAction -Action Shutdown -MachineName $machines
}

$machines = Get-BrokerMachine -MachineName AD\ECE-Staff-*
Set-BrokerMachineMaintenanceMode -InputObject $machines $false
New-BrokerHostingPowerAction -Action Shutdown -MachineName $machines



#PowerCLI
#Connect to Vcenter
connect-viserver callisto.ad.gatech.edu

#Export list of VM with their diff disks name and type based on naming scheme through VMware PowerCli
#Get-vm  ece-staff-*| get-harddisk | select Parent,StorageFormat,Filename | Export-Csv C:\Users\matthew\Desktop\ece-staff_disks.csv –NoTypeInformation
 

#Get list of source vms. 
(get-folder 'ece-staff'| get-vm -name ece-staff-*).name | sort-object | out-file c:\users\matthew\ece-staff-VMs.txt


$DestinationDatastore = 'rascasse7-vlab-ssd1'
$Destinationvmhost = 'vdi-r740-29.esx.gatech.edu'
$VMFolder= 'Ece-Staff-v2'
$VMs = get-content "C:\Users\matthew\Desktop\ece-staff-VM-part1.txt"
##  $VMS = Get-Folder -name Ece-Staff | Get-VM

#Clone VM to ESX 6.7
Write-host (get-date) - "Start Clone Job"
ForEach ($VM in $VMs) {
Write-host (get-date) - "Cloning $VM" 
New-VM -Name "$VM-v2" -VM $VM -Location $VMFolder -Datastore $DestinationDatastore -VMHost $Destinationvmhost
}

Write-host (get-date) - "Clone Job Completed"


#Update VM Compatibility Version on cloned VM 
#Also Works Well from WebInterface   
$VMConfig = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
$VMConfig.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
$VMConfig.ScheduledHardwareUpgradeInfo.UpgradePolicy = [VMware.Vim.ScheduledHardwareUpgradeInfoHardwareUpgradePolicy]::onSoftPowerOff
$VMConfig.ScheduledHardwareUpgradeInfo.VersionKey = “vmx-15”

foreach($vm in ($VMs)){
    $vmname = Get-VM -Name $vm-v2
    $vmname.ExtensionData.ReconfigVM_Task($VMConfig)
} 


#Update VMWare Tools
ForEach ($VM in $VMs){ 
Update-Tools -VM $VM-v2 -Verbose
}





New-BrokerMachine -CatalogUid 1194 -MachineName 'AD\machine'


#Example of Cirtix Machine Catalog Import Format
[VirtualMachinePath],[ADComputerAccount],[AssignedUsers],[VDAVersion]
XDHyp:\Connections\BCDC-VDI\VDI BCDC.datacenter\M10-GPU.cluster\ece-staff-12-v2.vm,AD\ece-staff-12$,AD\km105,Unknown
