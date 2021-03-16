connect-viserver callisto.ad.gatech.edu 

#Define Legacy Build Version
$ESXbuild = "15256549"

#Defince Vcenter
$vcenter = "callisto.ad.gatech.edu"

#Define Cluster
$Cluster = "K2-6.5"


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
