#Script for New Static VM
#mfranklin 1-2021
#BCDC ONLY. Not Ready for CODA

#Set Validated Parameters
Param(
[Parameter(Mandatory=$true)][string] $Unit,
[Parameter(Mandatory=$true)][string] $VMname,
[Parameter(Mandatory)][ValidateSet("K2-6.5","M10-GPU","NonGPU")] $ClusterName,
[Parameter(Mandatory)][ValidateSet("64","128","224","256","320")] $DiskSize,
[Parameter(Mandatory)][ValidateSet("4","8","12","16")] $Memory,
[Parameter(Mandatory)][ValidateSet("COB-6.5-1275","COE-6.5-1242-Persistent","OIT-6.5-1272-Persistent","EIS-6.5-1528")] $Network,
[Parameter(Mandatory)][ValidateSet("2","4")] $NumCPU

)
    
switch ($ClusterName) {
    "K2-6.5"{ $HostName = "vdi-r720g-01.esx.gatech.edu"; $Template = "Win10-1909-Dec2020"}
    "M10-GPU" {$HostName = "vdi-r730-03.esx.gatech.edu"; $Template = "Win10-1909-Dec2020-GPU"}
    "NonGPU" {$HostName = Get-Cluster "NonGPU"| Get-VMHost | Get-Random; $Template = "Win10-1909-Dec2020"}
    Default {}
}


<#
If (!($UnitName) {$UnitName = Read-Host "Please enter unit name abbreviation (ie: OIT)"}
#>
$OU="OU=PersistentDesktops,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu"
$Administrators="AD\Xen-$Unit-Admins" #Format "DOMAIN\Username" 
$SourceCS = 'Source-Customization-DoNotDelete'
$NewCS ="$VMname"
$DataStore = 'rascasse7-vlab-ssd1'


#Import Modules
import-module ActiveDirectory

#Create New OU 
$TargetOU = "OU=$Unit,$OU"
Write-Output "Create New OU $TargetOU"
New-ADOrganizationalUnit -Name $Unit -Path $OU


#Create new computer object
Write-Output "Create New Computer Object $VMname"
New-ADComputer -Name $VMname -SamAccountName $VMname -Path "$TargetOU"


#Load PS Module and COnnect to Vcenter
Get-Module -ListAvailable VM* | Import-Module
connect-viserver callisto.ad.gatech.edu

# Create New Vcenter VMFolder
$VMFolder = "$Unit-Staff"
Write-Output "Create new VM Folder $VMFolder" 
New-Folder -Name $VMFolder -Location (Get-Folder "$Unit")

#Get Source OS CustomSpecification and clone CustomSpec as NonPersistent. (NonPersistent will auto delete)
Write-Output "Create Customization Specification and Customize $VMname"
$OSCusSpec = Get-OSCustomizationSpec -Name $SourceCS | New-OSCustomizationSpec -Name $NewCS -Type NonPersistent
#$OSCusSpec = Get-OSCustomizationSpec -Name $SourceCS | New-OSCustomizationSpec -Name $NewCS -Type Persistent

#Test Splatting hash table
$osspecArgs = @{
    Orgname = $Unit
    NamingScheme = 'fixed'
    NamingPrefix = $VMname
    GuiRunOnce = "cmd.exe /C Powershell.exe –ExecutionPolicy Bypass -file C:\installs\Powershell-Setup-MasterImage.ps1",
    "cmd.exe /C NET LOCALGROUP Administrators $Administrators /add",
    "net user administrator /active:no",
    "sc stop wuauserv",
    "sc config wuauserv start= disabled"
}

Set-OSCustomizationSpec $NewCS @osspecArgs


# Deploy Virtual Machine, and wait for the task to complete. 
Write-Output "Deploy New VM $VMname"
$task = New-VM -Name $VMname -Template $Template -VMHost $HostName -Location $VMFolder -Datastore $Datastore -OSCustomizationSpec $NewCS
Wait-Task -Task $task

#Configure VM's virtual hardware 
Write-Output "Configure $VMname Virtual Harddisk"
Get-HardDisk $VMname | Set-HardDisk -CapacityGB $DiskSize -Confirm:$false
Write-Output "Configure $VMname Virtual RAM & CPU"
Set-VM -VM $VMname -MemoryGB $Memory -NumCpu $NumCPU -Confirm:$false
Write-Output "Configure $VMname Virtual Network Interface"
Get-NetworkAdapter -VM $VMname | Set-NetworkAdapter -Portgroup $Network -confirm:$false
#Consider Add-VGPU
Start-Sleep -Seconds 30

#Start VM and Wait for CustomSpec to apply. VM should auto join domain. 
Write-Output "Starting VM $VMname"
Start-VM -VM $VMname
Start-Sleep -Seconds 600

#Update Vmware Tools and wait
Write-Output "Updating VMware Tools"
Get-VM $VMname | % { get-view $_.id } | Where-Object {$_.Guest.ToolsVersionStatus -like "guestToolsNeedUpgrade"} | Update-Tools -VM {$_.Name} -Verbose
Start-Sleep -Seconds 360

#Shutdown VM and wait
Write-Output "Shutdown VM $NewVM"
Shutdown-VMGuest $VMname -confirm:$false
Start-Sleep -Seconds 120

#Take base snapshot
Write-Output "Taking Snapshot"
New-Snapshot -VM $VMname -Name 'Base' -Description "From $Template"
Start-Sleep -Seconds 15

#Power on New VM
Write-Output "Power Up $VMname for customer"
Start-VM -VM $VMname


#If CustomSpec is 'Persistent' Remove the CustomSpec
#Remove-OSCustomizationSpec $NewCS -Confirm:$false