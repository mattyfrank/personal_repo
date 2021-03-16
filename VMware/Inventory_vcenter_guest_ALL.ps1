#Get vcenter cluster VMs, Configured and Running OS

#select Vcenter
$viserver = "europa.ad.gatech.edu"
#,"ganymede.ad.gatech.edu"

#select properties, a full list is available with get-view
$properties = "Name", "Guest.GuestFullName", "Runtime.PowerState" 

#connect to vcenter
Connect-VIServer -Server $viserver -Protocol https 

Get-View -ViewType VirtualMachine -Property $properties |

Select -Property Name,

    @{N="PowerState";E={$_.Runtime.PowerState}}, 
    
    @{N="Configured OS";E={$_.Config.GuestFullName}}, 
    
    @{N="Running OS";E={$_.Guest.GuestFullName}} |
    
Export-Csv $viserver-vms.csv -NoTypeInformation -UseCulture