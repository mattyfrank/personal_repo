#returns "domain\namespace"
dfsutil.exe server gtad-dfs01.ad.gatech.edu

#dfsutil.exe root export \\contoso.com\<DomainNamespace1> C:\dir1\a.txt 
dfsutil.exe root export \\ad.gatech.edu\gtfs C:\backup\dfs_gtfs_config.txt 

#Get-DfsnRoot -computername <computername> | where type -NotMatch "Standalone"
Get-DfsnRoot -computername gtad-dfs01.ad.gatech.edu | where type -NotMatch "Standalone"
#Get-DfsnRoot -computername gtad-dfs02.ad.gatech.edu | where type -NotMatch "Standalone"
#Get-DfsnRoot -computername gtad-dfs03.ad.gatech.edu | where type -NotMatch "Standalone"
#Get-DfsnRoot -computername gtad-dfs04.ad.gatech.edu | where type -NotMatch "Standalone"

#

Get-DFSNRootTarget -path \\ad.gatech.edu\adminfinfs$                                                        
Get-DFSNRootTarget -path \\ad.gatech.edu\bmedfs$                                                        
Get-DFSNRootTarget -path \\ad.gatech.edu\ceefs$                                         
Get-DFSNRootTarget -path \\ad.gatech.edu\chbefs$                                   
Get-DFSNRootTarget -path \\ad.gatech.edu\coafs$                                    
Get-DFSNRootTarget -path \\ad.gatech.edu\devfs$                                                                
Get-DFSNRootTarget -path \\ad.gatech.edu\dlpefs$                                                                     
Get-DFSNRootTarget -path \\ad.gatech.edu\ecefs$                                                                        
Get-DFSNRootTarget -path \\ad.gatech.edu\enrsrvfs$                                                                 
Get-DFSNRootTarget -path \\ad.gatech.edu\gradfs$                                                         
Get-DFSNRootTarget -path \\ad.gatech.edu\gtpefs$                                                                      
Get-DFSNRootTarget -path \\ad.gatech.edu\mefs$                                                            
Get-DFSNRootTarget -path \\ad.gatech.edu\neetracfs$                                                                         
Get-DFSNRootTarget -path \\ad.gatech.edu\oiteisfs$                                                                           
Get-DFSNRootTarget -path \\ad.gatech.edu\gtfs     

#
#

#(Get-DfsnRootTarget –Path <Namespace>).Count 
(Get-DFSNRootTarget -path \\ad.gatech.edu\adminfinfs$).count
(Get-DFSNRootTarget -path \\ad.gatech.edu\bmedfs$).count
(Get-DFSNRootTarget -path \\ad.gatech.edu\ceefs$).count
(Get-DFSNRootTarget -path \\ad.gatech.edu\chbefs$).count
(Get-DFSNRootTarget -path \\ad.gatech.edu\coafs$).count
(Get-DFSNRootTarget -path \\ad.gatech.edu\devfs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\dlpefs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\ecefs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\enrsrvfs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\gradfs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\gtpefs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\mefs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\neetracfs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\oiteisfs$).count
(Get-DfsnRootTarget -path \\ad.gatech.edu\gtfs).count

#
#

#Remove-DfsnRootTarget –TargetPath <NamespaceRootTarget>
Remove-DfsnRootTarget -TargetPath \\GTAD-DFS01\adminfinfs$ 
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\bmedfs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\ceefs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\chbefs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\coafs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\devfs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\dlpefs$ 
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\ecefs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\enrsrvfs$ 
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\gradfs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\gtpefs$ 
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\mefs$  
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\neetracfs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\oiteisfs$
Remove-DfsnRootTarget -TargetPath \\gtad-dfs01\gtfs 

#
#

#Set-DfsnServerConfiguration –ComputerName <ServerName> –UseFqdn $true 
Set-DfsnServerConfiguration –ComputerName gtad01.ad.gatech.edu –UseFqdn $true

net stop dfs; net start dfs

#New-DfsnRootTarget – TargetPath <RootTarget> [-Path <Namespace>]
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\adminfinfs$" -path "\\ad.gatech.edu\adminfinfs$"
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\bmedfs$" -path "\\ad.gatech.edu\bmedfs$"
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\ceefs$" -path "\\ad.gatech.edu\ceefs$" 
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\chbefs$" -path "\\ad.gatech.edu\chbefs$"  
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\coafs$" -path "\\ad.gatech.edu\coafs$" 
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\devfs$" -path "\\ad.gatech.edu\devfs$"  
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\dlpefs$" -path "\\ad.gatech.edu\dlpefs$" 
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\ecefs$" -path "\\ad.gatech.edu\ecefs$"   
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\enrsrvfs$" -path "\\ad.gatech.edu\enrsrvfs$"
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\gradfs$ " -path "\\ad.gatech.edu\gradfs$"
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\gtpefs$" -path "\\ad.gatech.edu\gtpefs$" 
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\mefs$" -path "\\ad.gatech.edu\mefs$"  
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\neetracfs$" -path "\\ad.gatech.edu\neetracfs$"  
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\oiteisfs$" -path "\\ad.gatech.edu\oiteisfs$"
New-DfsnRootTarget -TargetPath "\\gtad-dfs01.ad.gatech.edu\gtfs" -path "\\ad.gatech.edu\gtfs" 

#
#

#dfsutil.exe root import set C:\dir1\a.txt \\contoso.com\<DomainNamespace1>
dfsutil.exe root import set "C:\backup\dfs_gtfs_config.txt" "\\ad.gatech.edu\gtfs"