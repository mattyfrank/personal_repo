#Script for repeat functions for VLAB administration
#mfranklin 01-2021
#CODA Only 

#IMPROVEMENTS#
#########################
###Add Error Catching###
#########################
#####Create a Module#####
#########################
##Examples of Functions##
#New-UPM - Makes new Folder and GPO settings
#New-AD - Makes new OU and new Computer objects
#New-VM - Deploy vm
#New-IMG - All of the above. 
##############################
#Build switch for Datacenter#
##############################
#BCDC-
#$vcenter="callisto.ad.gatech.edu"
#connect-viserver $vcenter
#$NewFolder="\\nas2-upm.matrix.gatech.edu\vlab_upm1\$UnitName-$Year"
#$DataStore = 'rascasse7-vlab-ssd1'
###   ###   ###   ###   ###   ###   ###
#CODA
#$vcenter="coda01c03vc01.ad.gatech.edu"
#connect-viserver $vcenter
#$NewFolder="\\coda-vdi-upm.nas.gatech.edu\coda-vdi-upm\$UnitName-$Year"
#$DataStore = 'manta1_vlab_ssd'
##############################


#Set Validated Parameters
Param(
[Parameter(Mandatory=$true)][string] $UnitName,
[Parameter(Mandatory=$true)][string] $Year,
[Parameter(Mandatory)][ValidateSet("CODA01-C03-T4","CODA01-C03-M10")] $ClusterName,
[Parameter(Mandatory)][ValidateSet("64","128","256","320")] $DiskSize,
[Parameter(Mandatory)][ValidateSet("4","8","12","16")] $Memory,
[Parameter(Mandatory)][ValidateSet("CODA01-C03-VLAN1295","CODA01-C03-VLAN1328","CODA01-C03-VLAN344")] $Network,
[Parameter(Mandatory)][ValidateSet("2","4")] $NumCPU

)
    
switch ($ClusterName) {
    "CODA01-C03-M10"{ $HostName = "coda01c03esx08.esx.gatech.edu"; $Template = "Win10-1909-Dec2020"}
    "CODA01-C03-T4" {$HostName = "coda01c03esx11.esx.gatech.edu"; $Template = "Win10-1909-Dec2020"}
    Default {}
}


<#
If (!($UnitName) {$UnitName = Read-Host "Please enter unit name abbreviation (ie: OIT)"}
#>

$NewOU="$UnitName-$Year"
$OUPath="OU=$UnitName,OU=VDI,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu"
$MasterImageName="$UnitName-$Year-IMG"
$SourceGPO="XEN-FSLOGIX-Win10-BCDC"
#$SourceGPO="XEN-FSLOGIX-Win10-CODA"
$NewGPO="Xen-FSLogix-$UnitName-$Year"
$Administrators="AD\Xen-$UnitName-Admins" #Format "DOMAIN\Username" 
$NewFolder="\\coda-vdi-upm.nas.gatech.edu\coda-vdi-upm\$UnitName-$Year"
$NewVM ="$UnitName-$Year-IMG"
$SourceCS = "Source-Customization-Coda"
$NewCS ="$NewVM"
$DataStore = 'manta11_vlab_hsata'

#Region New Directory for FSLogix User Profiles-

#Create a New Directory
Write-Output "Add Folder: $NewFolder"
New-Item -Path $NewFolder -ItemType Directory

#Disable Folder Inheritance
Write-Output "Remove Inheritance"
icacls "$Folder" /inheritance:d

icacls "$Folder" /reset

#Remove Permission for Everyone
Write-Output "Remove Everyone"
icacls $Folder /remove 'NT Authority\Everyone' /t /c

Write-Output "Set Permissions on User Profiles"
$objACL = Get-ACL -Path $Folder
$objACL.SetAccessRuleProtection($True, $False)

$FullRights = [System.Security.AccessControl.FileSystemRights]::FullControl
$ModifyRights = [System.Security.AccessControl.FileSystemRights]::Modify
$InheritanceYes = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit","ObjectInherit"
$InheritanceNo = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$objType =[System.Security.AccessControl.AccessControlType]::Allow 

$objUser = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.SetAccessRule($objACE) 

$objUser = New-Object System.Security.Principal.NTAccount("$Administrators") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

$objUser = New-Object System.Security.Principal.NTAccount("AD\XEN-OUADMINS") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE)

$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$objUser = New-Object System.Security.Principal.NTAccount("CREATOR OWNER") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $FullRights, $InheritanceYes, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

$objUser = New-Object System.Security.Principal.NTAccount("NT Authority\Authenticated Users") 
$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $ModifyRights, $InheritanceNo, $PropagationFlag, $objType) 
$objACL.AddAccessRule($objACE) 

(Get-Item $Folder).SetAccessControl($objACL)


#EndRegion


#Region New OU, New Computer Object, and New GPO-

#Import Modules
import-module ActiveDirectory

#Create New OU 
$TargetOU = "OU=$NewOU,$OUPath"
Write-Output "Create New OU: $TargetOU"
New-ADOrganizationalUnit -Name $NewOU -Path $OUPath

#Create new computer object
Write-Output "Create New Computer Object: $MasterImageName"
New-ADComputer -Name $MasterImageName -SamAccountName $MasterImageName -Path $TargetOU

#Add Computer Object to Security Group for Images
Write-Output "Adding $($MasterImageName.Name) to AD Security Group 'AD\Golden-Images'"
Add-ADGroupMember 'Golden-Images' -Members (Get-AdComputer $MasterImageName)

#Create new GPO from source GPO, preserving permissions. 
Write-Output "Create New GPO: $NewGPO"
Copy-GPO -SourceName $SourceGPO -TargetName $NewGPO -CopyAcl
Start-Sleep -Seconds 10

#Link new gpo to new OU
Write-Output "Link GPO $NewGPO to OU $TargetOU"
New-GPLink -Name $NewGPO -Target "OU=$NewOU,$OUPath" -LinkEnabled Yes

#Edit New GPO to reflect New Folder Location
Write-Output "Edit GPO $NewGPO FSLogix VHD Location and Redirections"
Set-GPRegistryValue -Name $NewGPO -Key "HKLM\Software\FSLogix\Profiles" -ValueName "VHDLocations" -Value $($NewFolder) -Type String | Out-Null
Set-GPRegistryValue -Name $NewGPO -Key "HKLM\Software\Policies\FSLogix\ODFC" -ValueName "VHDLocations" -Value $($NewFolder) -Type String | Out-Null
Set-GPRegistryValue -Name $NewGPO -Key "HKLM\Software\FSLogix\Profiles" -ValueName "RedirXMLSourceFolder" -Value $("\\coda-vdi-upm.nas.gatech.edu\coda-vdi-upm\Redirections") -Type String | Out-Null

#EndRegion


#Region Create New VM from Template, Create a Custom Specification, Apply CustomSpec to VM-

#Load PS Module and Connect to Vcenter
Get-Module -ListAvailable VM* | Import-Module
connect-viserver coda01c03vc01.ad.gatech.edu

# Create New Vcenter VMFolder
$VMFolder = "$UnitName-$Year"
Write-Output "Create new VM Folder: $VMFolder" 
New-Folder -Name $VMFolder -Location (Get-Folder "$UnitName")

#Get Source OS CustomSpecification and clone CustomSpec as NonPersistent. (NonPersistent will auto delete)
Write-Output "Create Customization Specification and Customize: $NewVM"
$OSCusSpec = Get-OSCustomizationSpec -Name c | New-OSCustomizationSpec -Name $NewCS -Type NonPersistent
#$OSCusSpec = Get-OSCustomizationSpec -Name $SourceCS | New-OSCustomizationSpec -Name $NewCS -Type Persistent

#Test Splatting hash table
$osspecArgs = @{
    Orgname = $UnitName
    NamingScheme = 'fixed'
    NamingPrefix = $NewVM
    GuiRunOnce = "cmd.exe /C Powershell.exe –ExecutionPolicy Bypass -file C:\installs\Expand-Partition.ps1",
    "cmd.exe /C NET LOCALGROUP Administrators $Administrators /add",
    "net user administrator /active:no",
    "sc stop wuauserv",
    "sc config wuauserv start= disabled"
}

Set-OSCustomizationSpec $NewCS @osspecArgs


# Deploy Virtual Machine, and wait for the task to complete. 
Write-Output "Deploy New VM: $NewVM"
$task = New-VM -Name $NewVM -Template $Template -VMHost $HostName -Location $VMFolder -Datastore $Datastore -OSCustomizationSpec $NewCS
Wait-Task -Task $task

#Configure VM's virtual hardware 
Write-Output "Configure $NewVM Virtual Harddisk"
Get-HardDisk $NewVM | Set-HardDisk -CapacityGB $DiskSize -Confirm:$false
Write-Output "Configure $NewVM Virtual RAM & CPU"
Set-VM -VM $NewVM -MemoryGB $Memory -NumCpu $NumCPU -Confirm:$false
Write-Output "Configure $NewVM Virtual Network Interface"
#Get-NetworkAdapter -VM $NewVM | Set-NetworkAdapter -Portgroup $Network -StartConnected $true -confirm:$false
Get-VM $NewVM | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $Network -StartConnected:$true  -confirm:$false
#Consider Add-VGPU
Start-Sleep -Seconds 30

#Start VM and Wait for CustomSpec to apply. VM should auto join domain. 
Write-Output "Starting VM: $NewVM"
Start-VM -VM $NewVM
Start-Sleep -Seconds 600

#Update Vmware Tools and wait
Write-Output "Updating VMware Tools"
Get-VM $NewVM | % { get-view $_.id } | Where-Object {$_.Guest.ToolsVersionStatus -like "guestToolsNeedUpgrade"} | Update-Tools -VM {$_.Name} -Verbose
Start-Sleep -Seconds 360

#Shutdown VM and wait
Write-Output "Shutdown VM: $NewVM"
Shutdown-VMGuest $NewVM -confirm:$false
Start-Sleep -Seconds 120

#Take base snapshot
Write-Output "Taking Snapshot"
New-Snapshot -VM $NewVM -Name 'Base' -Description "From $Template"
Start-Sleep -Seconds 15

#Power on New VM
Write-Output "Power Up $NewVM for customer"
Start-VM -VM $NewVM


#If CustomSpec is 'Persistent' Remove the CustomSpec
#Remove-OSCustomizationSpec $NewCS -Confirm

#EndRegion


<#
#Region Install Agents

#Agents/Drivers can be installed with powershell/Choco with RunOnce, or Agents can be preinstalled.

#Install VMware Tools
setup.exe /S /v "/qn REBOOT=R ADDLOCAL=ALL REMOVE=SVGA"


#Install VDA
./VDAWorkstationSetup_1912.exe /controllers "coda-xd7-srv1.ad.gatech.edu coda-xd7-srv2.ad.gatech.edu" /noreboot /quiet /enable_remote_assistance /virtualmachine /includeadditional "Citrix Supportability Tools","Machine Identity Service","Citrix User Profile Manager","Citrix User Profile Manager WMI Plugin" /exclude "Citrix Files for Outlook","Citrix Files for Windows","Citrix Telemetry Service","Citrix Personalization for App-V - VDA","Personal vDisk" /components vda /mastermcsimage 


#Testing Install NVID 
#had to manually extract setup.exe from self-exracting installer
#C:\Installs\426.94_grid_win10_server2016_server2019_64bit_international.exe

$install_args = "-passive -noreboot -noeula -nofinish -s"
Start-Process -FilePath "C:\Installs\452.57\Win10_64\International\setup.exe" -ArgumentList $install_args -wait

#Install FSL
#FSLogixAppsSetup.exe -ArgumentList /install /quiet /norestart

# Define variables
$AgentInstaller = "FSLogixAppsSetup.exe"
$Switches = "/install /quiet /norestart"
# Install the FSLogix Apps agent
Start-Process -Wait ".\$AgentInstaller" -ArgumentList $Switches

##Optimize Windows Hard Coded for win10-1909
#Analyze Services/Features 
Set-ExecutionPolicy Bypass -Scope Process -Force; & '.\CtxOptimizerEngine.ps1' -source 'C:\Installs\CitrixOptimizer\Templates\Citrix_Windows_10_1909.xml' -mode analyze
#Execute Optimizations 
Set-ExecutionPolicy Bypass -Scope Process -Force; & '.\CtxOptimizerEngine.ps1' -source 'C:\Installs\CitrixOptimizer\Templates\Citrix_Windows_10_1909.xml' -mode execute

#EndRegion
#>




<#
#Cleanup
connect-viserver callisto.ad.gatech.edu
Get-GPO -Name "Xens-FSLogix-COE-Test" | Remove-GPO -Confirm:$false
Get-ADComputer -Identity "COE-Test-IMG" | Remove-ADComputer -Confirm:$false
Get-ADOrganizationalUnit -Identity "OU=COE-Test,OU=COE,OU=VDI,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false
Get-Item -Path "\\nas2-upm.matrix.gatech.edu\vlab_upm1\COE-Test" | Remove-Item -Confirm:$false
Get-OSCustomizationSpec -Name "COE-Test-IMG" | Remove-OSCustomizationSpec -Confirm:$false
Get-VM -Name "COE-Test-IMG" | Shutdown-VMGuest | Remove-VM -Confirm:$false
Get-Folder -Name "COE-Test" | Remove-Folder -Confirm:$false
#>
