#Get VMs running VMware TOols 10.3.0

$ListofVMs = Get-VM | % { get-view $_.id } |Where-Object {$_.Guest.ToolsVersion -like "10336"} |select name, @{Name=“ToolsVersion”; Expression={$_.config.tools.toolsversion}}, @{ Name=“ToolStatus”; Expression={$_.Guest.ToolsVersionStatus}}

ForEach ($VM in $ListofVMs){Update-Tools -NoReboot -VM $VM.Name -Verbose}




#Get and Update VMs running VMware Tols that are out of date

$OutofDateVMs = Get-Folder -name Testing | Get-VM | % { get-view $_.id } |Where-Object {$_.Guest.ToolsVersionStatus -like "guestToolsNeedUpgrade"} |select name, @{Name=“ToolsVersion”; Expression={$_.config.tools.toolsversion}}, @{ Name=“ToolStatus”; Expression={$_.Guest.ToolsVersionStatus}}
 
ForEach ($VM in $OutOfDateVMs){Update-Tools -NoReboot -VM $VM.Name -Verbose}