function Get-VMLogLastEvent{
    param(
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][PSObject[]]$VM,
    [string]$Path=$env:TEMP
    )
 
    process{   
        $report = @()

        foreach($obj in $VM){
            if($obj.GetType().Name -eq "string"){
                $obj = Get-VM -Name $obj
            }
            $logpath = ($obj.ExtensionData.LayoutEx.File | ?{$_.Name -like "*/vmware.log"}).Name
            $dsName = $logPath.Split(']')[0].Trim('[')
            $vmPath = $logPath.Split(']')[1].Trim(' ')
            $ds = Get-Datastore -Name $dsName
            $drvName = "MyDS" + (Get-Random)
            $localLog = $Path + "\" + $obj.Name + ".vmware.log"
            New-PSDrive -Location $ds -Name $drvName -PSProvider VimDatastore -Root '\' | Out-Null
            Copy-DatastoreItem -Item ($drvName + ":" + $vmPath) -Destination $localLog -Force:$true
            Remove-PSDrive -Name $drvName -Confirm:$false
        
            $lastEvent = Get-Content -Path $localLog -Tail 1
            Remove-Item -Path $localLog -Confirm:$false
            
            $row = "" | Select VM, EventType, Event, EventTime
            $row.VM = $obj.Name
            ($row.EventTime, $row.EventType, $row.Event) = $lastEvent.Split("|")
            $row.EventTime = $row.EventTime | Get-Date
            $report += $row
         }
         $report        
    }
} 

$Report = @()   
$VMs = Get-VM | Where {$_.PowerState -eq "PoweredOff"}  
$Datastores = Get-Datastore | Select Name, Id  
$PowerOffEvents = Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue) | where {$_ -is [VMware.Vim.VmPoweredOffEvent]} | Group-Object -Property {$_.Vm.Name}  
  
foreach ($VM in $VMs) {  
    $lastPO = ($PowerOffEvents | Where { $_.Group[0].Vm.Vm -eq $VM.Id }).Group | Sort-Object -Property CreatedTime -Descending | Select -First 1 
    $lastLogTime = "";
    
    # If no event log detail, revert to vmware.log last entry which takes more time...
    if (($lastPO.PoweredOffTime -eq "") -or ($lastPO.PoweredOffTime -eq $null)){
        $lastLogTime = (Get-VMLogLastEvent -VM $VM).EventTime
    }
  
    $row = "" | select VMName,Powerstate,OS,Host,Cluster,Datastore,NumCPU,MemMb,DiskGb,PoweredOffTime,PoweredOffBy,LastLogTime
    $row.VMName = $vm.Name  
    $row.Powerstate = $vm.Powerstate  
    $row.OS = $vm.Guest.OSFullName  
    $row.Host = $vm.VMHost.name  
    $row.Cluster = $vm.VMHost.Parent.Name  
    $row.Datastore = $Datastores | Where{$_.Id -eq ($vm.DatastoreIdList | select -First 1)} | Select -ExpandProperty Name  
    $row.NumCPU = $vm.NumCPU  
    $row.MemMb = $vm.MemoryMB  
    $row.DiskGb = Get-HardDisk -VM $vm | Measure-Object -Property CapacityGB -Sum | select -ExpandProperty Sum  
    $row.PoweredOffTime = $lastPO.CreatedTime  
    $row.PoweredOffBy   = $lastPO.UserName
    $row.LastLogTime = $lastLogTime
    $report += $row  
}  
  
# Output to screen  
$report | Sort Cluster, Host, VMName | Select VMName, Cluster, Host, NumCPU, MemMb, @{N='DiskGb';E={[math]::Round($_.DiskGb,2)}}, PoweredOffTime, PoweredOffBy | ft -a  
  
# Output to CSV - change path/filename as appropriate  
$report | Sort Cluster, Host, VMName | Export-Csv -Path "C:\Users\matthew\Desktop\Powered_Off_VMs.csv" -NoTypeInformation -UseCulture  

