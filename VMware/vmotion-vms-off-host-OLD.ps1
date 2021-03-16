<#
mfranklin7@gatech.edu
Feb 2021
Migrate All VMs off of a target ESX Host,
and place target ESXi host into Maintenance Mode
How To Use-
Set ESXi Legacy Build version and vcenter address.
Run script interactively.
manual mode-
user will provide source and destination hosts, 
then move all the VMs' between the two.
HostName does not need to be FQDN, searches for VMhost that matches user input.
Optional: shutdown vm step commented out.
automated method-
Logic based on ESXi Build Number & Dell Server Model Number. 
VMs will automatically evacuate any hosts running legacy build version. 
VMs will move to hosts with newer build version, zero VMs, 
and source & target ESX host Dell model number match. 
Optional: processor type can be used as condition.
#>

#-------------------------------------------------#
#Automatically Define Target and Destination Host.# 
#-------------------------------------------------#

#Define Legacy Build Version
$ESXbuild = "15256549"

#Defince Vcenter
$vcenter = "callisto.ad.gatech.edu"

#Define Cluster
$Cluster = "K2-6.5"

#Define Log Path
$logpath = "C:\logs\VM-migrations\Vmotion-$(get-date -f yyyy-MM-dd-HH.mm).txt"

#Verify the log directory exists
If(!(Test-Path $logpath)){
    Write-Output "Log path not found, creating folder."
    New-Item $logpath 
}

#Start Logging
Start-Transcript -Path $logpath

#Connect to vcenter
connect-viserver $vcenter

#Locate ESX Hosts that matches above build number
$LegacyHosts = Get-cluster $Cluster | Get-VMHost | Where {$_.build -eq $ESXbuild} |sort $_.Name

#For Each Host needng evacuation
ForEach ($LegacyHost in $LegacyHosts) 
{
  
    #Get VM Hosts with Build Greater Than Build, Host is in Service, and Host has Less than 1 VM. 
    #[0] Selects the first item in the variable
    $TargetHost = ( Get-Cluster $Cluster | Get-VMHost | Where {$_.build -gt $ESXbuild -and $_.State -like 'Connected'} | Where {($_ | Get-VM).count -lt 1} | sort $_.Name )[0]
    
    Write-Host -ForegroundColor DarkYellow "This is the source host" $LegacyHost.name.split(".")[0]
    Write-Host ""
    Write-Host -ForegroundColor DarkYellow "This is the target host" $TargetHost.name.split(".")[0]
    Write-Host ""
    Write-Host -ForegroundColor DarkYellow "Target Host " $TargetHost.name.split(".")[0] "has "($TargetHost |Get-VM).count "VMs"
    Write-Host ""
    Write-Host -ForegroundColor DarkYellow "Host Model match for Source Host: " $LegacyHost.name.split(".")[0] "& Target Host:" $TargetHost.name.split(".")[0]
    Write-Host ""
    Write-Host -ForegroundColor DarkYellow "Migrating VMs on" $LegacyHost.name.split(".")[0] "to" $Targethost.name.split(".")[0]
    Write-Host ""
    #Powershell_ISE Wait until Enter
    $userInput = read-host “Press y to continue...”
    If ($userInput -ne 'y') { write-output "exiting..."; exit 1 }
    
    #Get-VMs on Legacy Host
    $VirtualMachines = Get-VMHost $LegacyHost | Get-VM
                      
    #Move each VM on Legacy Host
    ForEach ($VM in $VirtualMachines)
    {
        #Graceful Shutdown VM OS
        #Shutdown-VMGuest -VM $vm -Confirm:$false

        #Force Power Off
        #Stop-VM -VM $vm -Confirm:$false
                                    
        Start-sleep -Seconds 1

        #Output VM and Destination Host
        Write-Host -ForegroundColor DarkYellow "Migrating: " $vm "to host" $Targethost.name.split(".")[0]
        Write-Host ""
                
        #Migrate VM to Destination Host
        Move-VM -VM $vm $Targethost
                
        #Wait for 1 second
        Start-sleep -Seconds 1

    } #End ForEach -Virtualmachines

    #Place the selected host into Maintenance Mode.
    Write-Host -ForegroundColor DarkYellow  "Placing Host" $LegacyHost.name.split(".")[0] "into Maintenance Mode"
    Write-Host ""

    #Set-VMHost $LegacyHost -State Maintenance
    Set-VMHost $LegacyHost -State Maintenance

    #Powershell_ISE Wait until Enter
    #Read-Host “Press ENTER to continue...”

} #End ForEach

$LegacyHosts = Get-cluster $Cluster | Get-VMHost | Where {$_.build -eq $ESXbuild -and $_.State -like 'Connected'} |sort $_.Name
ForEach ($VMHost in $LegacyHosts)
{
    Write-Host -ForegroundColor DarkYellow "Needs Update: $VMHost"
    Write-Host ""
}


Stop-Transcript




<#
#--------------------------------------------#
#Manually Define Target and Destination Host.# 
#--------------------------------------------#
# >
#$targethost = Get-VMHost -Name vdi-r740-21.esx.gatech.edu
#$desthost = Get-VMHost -Name vdi-r740-20.esx.gatech.edu

$targethost = read-host “Enter Name of ESX Host to evacuate.”
$desthost = read-host “Enter Name of Destination ESX Host.”
$domain = ".esx.gatech.edu"

Get-VMHost | where {$_.Name -like "$targethost*"}
$virtualmachines = Get-VMHost $targethost.name | Get-VM
$userInput = read-host “Migrate all VMs on $targethost to $desthost. Press Y to continue”
if ($userInput -ne 'y') { write-output "exiting..."; exit 1 }
	
foreach ($vm in $virtualmachines)
{
    #Graceful Shutdown VM OS
    #Shutdown-VMGuest -VM $vm -Confirm:$false
    #Force Power Off
    #Stop-VM -VM $vm -Confirm:$false
    Start-sleep -Seconds 1
    Write-Host -ForegroundColor DarkYellow "Migrating: " $vm "to host" $desthost.name.split(".")[0]
    Write-Host ""
    Move-VM -VM $vm $desthost
    Start-sleep -Seconds 1
}
#Place the selected host into Maintenance Mode.
Write-Host -ForegroundColor DarkYellow  "Placing Host" $targethost.name.split(".")[0] "into Maintenance Mode"
Set-VMHost $targethost.name -State Maintenance
 
$LegacyHosts = Get-cluster $Cluster | Get-VMHost | Where {$_.build -eq $ESXbuild -and $_.State -like 'Connected'} |sort $_.Name
ForEach ($VMHost in $LegacyHosts)
{
    Write-Host -ForegroundColor DarkYellow "Needs Update: "$VMHost.name.split(".")[0]
    Write-Host ""
}
#>