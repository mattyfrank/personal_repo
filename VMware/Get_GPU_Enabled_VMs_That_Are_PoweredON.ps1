#Count GPU Enabled and Powered On
Connect-VIServer -Server callisto.ad.gatech.edu
$GPUClusters = @("m10-esx6.5","m10-740-esx6.5","m60-esx6.5","m10-740-esx6.7","p40-esx6.5")
Get-Cluster $GPUClusters | Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"} | Measure-Object