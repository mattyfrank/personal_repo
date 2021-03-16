## Powershell Script for GT-CSR WVD Image
## Deploy Windows 10 MultiSession w/o Office
## Mount NetworkDrive, and Execute Script
## mfranklin7@gatech.edu
## updated Feb 2021

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\WVD-CSR-Console.ps1'

##Enable RSAT Capability
DISM.exe /Online /add-capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 /CapabilityName:Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 /CapabilityName:Rsat.CertificateServices.Tools~~~~0.0.1.0 /CapabilityName:Rsat.DHCP.Tools~~~~0.0.1.0 /CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0 /CapabilityName:Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.FileServices.Tools~~~~0.0.1.0 /CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.IPAM.Client.Tools~~~~0.0.1.0 /CapabilityName:Rsat.LLDP.Tools~~~~0.0.1.0 /CapabilityName:Rsat.NetworkController.Tools~~~~0.0.1.0 /CapabilityName:Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 /CapabilityName:Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 /CapabilityName:Rsat.ServerManager.Tools~~~~0.0.1.0 /CapabilityName:Rsat.Shielded.VM.Tools~~~~0.0.1.0 /CapabilityName:Rsat.StorageReplica.Tools~~~~0.0.1.0 /CapabilityName:Rsat.VolumeActivation.Tools~~~~0.0.1.0 /CapabilityName:Rsat.WSUS.Tools~~~~0.0.1.0 /CapabilityName:Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.SystemInsights.Management.Tools~~~~0.0.1.0

#Install chocolatey
& "\\gt-repo.ad.gatech.edu\configs$\InstallChocolatey.ps1"
choco upgrade chocolatey -y
choco upgrade chocolatey-core.extension -y

##Install FSLogix
choco upgrade fslogix -y -s='chocolatey'

#Install Office365 Enterprise Apps Semi-Annual Channel Release
$o365ConfigPath = "\\gt-repo.ad.gatech.edu\configs$\WVD-CSR-Console-Configuration.xml" 
choco upgrade office365proplus --params "/ConfigPath:$o365ConfigPath" -y

##Install OneDrive
choco upgrade microsoft-onedrive -y

#Install Free Apps
choco upgrade firefoxesr -packageParameters "MaintenanceService=false" -y
choco upgrade firefoxesr-vlab -y
choco upgrade googlechrome-vlab -y
choco upgrade microsoft-edge-vlab -y
choco upgrade notepadplusplus -y 
choco upgrade 7zip -y
choco upgrade imageglass -y

#Install CSR Admin (SysAdmin) Tools
choco upgrade winscp.install -y
choco upgrade securecrt -y
choco upgrade rdm -y
choco upgrade vscode.install -y
choco upgrade powershell-core -y
choco upgrade python -y
choco upgrade PowerBi -y
choco upgrade gt-sccm-console -y
choco upgrade beyondtrust-rep-console -y
#choco upgrade github-desktop-machine-wide -y ##Install by user
#choco upgrade veeam-backup-and-replication-console -y #Does not Work

#Install EndPoint Agents -Post Deployment
#choco upgrade fireeye -y --install-arguments='"INSTALLSERVICE=2"'
#choco upgrade qualysagent -y

##List all Choco Packages Installed Locally
choco list --local-only

## clean desktop icons
Remove-Item "c:\Users\*\Desktop\Firefox.lnk" -force
Remove-Item "c:\Users\*\Desktop\Google Chrome.lnk" -force
Remove-Item "c:\Users\*\Desktop\Microsoft Edge.lnk" -force
Remove-Item "c:\Users\*\Desktop\Visual Studio Code.lnk" -force
Remove-Item "c:\Users\*\Desktop\Power BI Desktop.lnk" -force
Remove-Item "c:\Users\*\Desktop\WinSCP.lnk" -force
Remove-Item "c:\Users\*\Desktop\GitHub Desktop.lnk" -force
Remove-Item "c:\Users\*\Desktop\SecureCRT 8.7.lnk" -force
Remove-Item "c:\Users\*\Desktop\Adobe Acrobat DC.lnk" -force
Remove-Item "c:\Users\*\Desktop\ImageGlass.lnk" -force


##Optimize Image

#Set Time to Eastern Time Zone
tzutil /s "Eastern Standard Time"
 
#Disable Auto-Updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

#TimeZone Redirection 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

#Disable Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

#Files for Post Deployment
$localpath = "C:\Installs"
$remotepath = "\\gt-repo.ad.gatech.edu\configs$\wvd-source-files"

#Create C:\Installs
Write-Output "Creating Directory: " $localpath 
New-Item $localpath -ItemType Directory

#Copy Post Deploy Script to C:\installs
Write-Output "Copy Post Deployment Script to " $localpath
Get-Item "$remotepath\post-deploy.ps1" | Copy-Item -Destination $localpath


#Copy ADM to C:\Installs
Write-Output "Copy ADML 7 ADMX Files to " $localpath
Get-Item "$remotepath\ADM Files.zip" | Copy-Item -Destination $localpath

#Copy WVD Optimization Scripts to C:\Installs
Write-Output "Copy Windows Virtual desktop Optimization to " $localpath
Get-Item "$remotepath\Virtual-Desktop-Optimization-Tool-master.zip" | Copy-Item -Destination $localpath

#Expand WVD Optimization Files
Write-Output "Expand Zipped Files"
Expand-Archive $LocalPath\'ADM Files.zip' -DestinationPath $localpath
Expand-Archive $LocalPath\'Virtual-Desktop-Optimization-Tool-master.zip' -DestinationPath $localpath

#Copy ADML/ADMX files
Write-Output "Copy ADML and ADMX files"
Get-ChildItem "$localpath\ADM Files\*.admx" | Copy-Item -Destination "C:\Windows\PolicyDefinitions"
Get-ChildItem "$localpath\ADM Files\en-US" | Copy-Item -Destination "C:\Windows\PolicyDefinitions\en-US"

#Start 1 Min Wait
Start-Sleep -Seconds 60

Write-Output "Cleanup files in " $localpath
Get-Item "$LocalPath\Virtual-Desktop-Optimization-Tool-master.zip" | Remove-Item -Force -Confirm:$false
Get-Item $LocalPath\'ADM Files.zip' | Remove-Item -Force -Confirm:$false
Get-Item $LocalPath\'ADM Files' | Remove-Item -Recurse -Force -Confirm:$false

#Start 5 Min Wait
Start-Sleep -Seconds 120

#Reboot
& shutdown -r -t 300

#After Reboot - 
#SysPrep and ShutDown.
#C:\Windows\system32\sysprep\sysprep.exe /generalize /shutdown /oobe



