#WVD NOTES May 2020 - Spring Preview Release. 

#AZWVD module replaces RDinfra
Install-Module -Name Az.DesktopVirtualization
Import-Module -Name Az.DesktopVirtualization

#Documentation was missing - Creates Refrence document
Get-Command -Module Az.DesktopVirtualization | select Name
Get-Command -Module Az.DesktopVirtualization | get-help  | out-file C:\Users\matthew\Desktop\AZ.txt

#Update AzureAD Module and Import
Update-Module -Name AzureAD
Import-Module AzureAD

#Updates AZ Module
Install-Module -Name Az -AllowClobber
Install-Module -Name Az -AllowClobber -Force

## Connect as - az-mfranklin7@gatech.edu
Connect-AzAccount
Connect-AzureAD

# FSLogix User Profiles UNC '\\azntap-54b4.ad.gatech.edu\fslogix-eastus'
# RootOUPath is "OU=WVD,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu"
# Image Name is "WVD-GEN-IMG-420"
#AZADID="482198bb-ae7b-4b25-8b7a-6d7f32faa083"
#SubscriptionID="c1835977-39e7-4415-a092-a77866f5afb8"

$ResourceGroupName = "WVD-HostGroup-General"
$HostPoolName = "Remote Workspace"
$GPUHostPoolName = "Remote Workspace wGPU"
$AppGroupName ="Remote Workspace-DAG"
$GPUAppGroupName ="Remote Workspace wGPU-DAG"

# Query Workspaces
Get-AzWvdWorkspace 

# Query Host Pools
Get-AzWvdHostPool

#Query Application Groups
Get-AzWvdApplicationGroup   

#Query and Remove Session Hosts
Get-AzWvdSessionHost -HostPoolName <hostpoolname> -Name <sessionhostname> -ResourceGroupName <resourcegroupname>
Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName
Remove-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName -Name 'WVD-GEN-1.ad.gatech.edu' -Force

#Rename Desktop/App with Friendly Name
Get-AzWvdDesktop -ApplicationGroupName $GPUAppGroupName  -ResourceGroupName $ResourceGroupName -Name  'SessionDesktop'
Update-AzWvdDesktop -ApplicationGroupName $GPUAppGroupName  -ResourceGroupName $ResourceGroupName -Name  'SessionDesktop' -FriendlyName 'Remote Workspace with GPU'  

Get-AzWvdApplication -GroupName $AppGroupName -ResourceGroupName $ResourceGroupName
Update-AzWvdApplication -ResourceGroupName <resourcegroupname> -ApplicationGroupName <appgroupname> -Name <applicationname> -FriendlyName <newfriendlyname>
 

# Query, Disconnect, Logoff User Sessions
# get-help Get-AzWvdUserSession -Examples
Get-AzWvdUserSession -HostPoolName $GPUHostPoolName -ResourceGroupName $ResourceGroupName 

Disconnect-AzWvdUserSession -ResourceGroupName $ResourceGroupName -HostPoolName $GPUHostPoolName -SessionHostName WVD-GPU-0.ad.gatech.edu

#Logs Off User Session
Remove-AzWvdUserSession -ResourceGroupName $ResourceGroupName -HostPoolName $GPUHostPoolName -SessionHostName WVD-GPU-0.ad.gatech.edu

#Remove or Disconnect?
get-help Remove-AzWvdUserSession -Examples      


#Force VM(s) to reboot.
Get-AzVM -ResourceGroupName $ResourceGroupName | where name -eq wvd-gen-0 | Restart-AzVM
Get-AzVM -ResourceGroupName $ResourceGroupName | where name -eq wvd-gen-1 | Stop-AzVM

#REBOOTS All VMs in ResourceGroup - 
#Get-AzVM -ResourceGroupName $ResourceGroupName | Restart-AzVM



#Refrences
Get-AzWvdApplication -GroupName $AppGroupName -ResourceGroupName $ResourceGroupName         
Get-AzWvdApplicationGroup       
Get-AzWvdDesktop -ApplicationGroupName $AppGroupName  -ResourceGroupName $ResourceGroupName            
Get-AzWvdHostPool               
Get-AzWvdRegistrationInfo -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName        
Get-AzWvdSessionHost -HostPoolName $HostPoolName -ResourceGroupName $ResourceGroupName             
Get-AzWvdStartMenuItem -ApplicationGroupName $AppGroupName -ResourceGroupName $ResourceGroupName           
Get-AzWvdUserSession -HostPoolName $GPUHostPoolName -ResourceGroupName $ResourceGroupName            
Get-AzWvdWorkspace         
 