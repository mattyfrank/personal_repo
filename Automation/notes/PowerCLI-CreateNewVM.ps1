# Get the OS CustomizationSpec and clone
$OSCusSpec = Get-OSCustomizationSpec -Name 'Source' | New-OSCustomizationSpec -Name 'New-CustomSpec' -Type NonPersistent

#Get updated Spec Object
$OSCusSpec = Get-OSCustomizationSpec -Name 'New-CustomSpec'

#Define Parameters
$NewVM=
$Template = Get-Template -Name 'Win10-1909-MDT'
$DiskSize=128
$Memory=8
$NumCPU=2
$Network='COE-6.5-1364-Non-Persistent'

#Get Cluster
$tgtClusterName = 'Non-GPU 6.5'
$cluster = Get-Cluster -Name $tgtClusterName

# Get a host within cluster
$VMHost = Get-Cluster $cluster | Get-VMHost | Get-Random

# Get datastore
$dsName = 'rascasse1-vlab-sas1'


#######################################################


# Deploy Virtual Machine and remove temp custom spec
$VM = New-VM -Name $NewVM -Template $Template -VMHost $VMHost -Datastore $Datastore -OSCustomizationSpec $OSCusSpec -DiskGB $DiskSize -MemoryGB $Memory -NumCpu $NumCPU -NetworkName $Network | Start-VM
Remove-OSCustomizationSpec $OSCusSpec -Confirm

########################################################

#Create Computer Object

$MasterImageName="SchoolName-Year-IMG"
$OUName="Year"
$OUPath="OU=OIT,OU=VDI,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu"

New-ADOrganizationalUnit -Name $OUName -Path $OUPath
New-ADComputer -Name $MasterImageName -SamAccountName $MasterImageName -Path $OUPath

#Create new UPM Directory 
New-Item -Path "FileSystem::\\nas2-upm.matrix.gatech.edu\vlab_upm1\New_Directory" -ItemType Directory

#New GPO (or copy existing GPO?)

#Link GPO to $OUPath


############################################################

#Pause to wait for deployment to finish
Pause

##################################

#Once Ready - Shutdown and Take Snapshot
Get-VM $NewVM | Shutdown-VMGuest
New-Snapshot -VM $NewVM -Name BaseLine -Description No Apps Installed

