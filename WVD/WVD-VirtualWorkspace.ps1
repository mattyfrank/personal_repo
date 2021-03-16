## Powershell Script for GT Virtual Workspace IMG
## Deploy Windows 10 MultiSession w/o Office
## Mount NetworkDrive, and Execute Script
## mfranklin7@gatech.edu
## updated Feb 2021

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\WVD-virtualworkspace.ps1'

#Install chocolatey
& "\\gt-repo.ad.gatech.edu\configs$\InstallChocolatey.ps1"
choco upgrade chocolatey -y
choco upgrade chocolatey-core.extension -y

##Install Free Apps
choco upgrade firefoxesr -packageParameters "MaintenanceService=false" -y
choco upgrade firefoxesr-vlab -y
choco upgrade googlechrome-vlab -y
choco upgrade microsoft-edge-vlab -y
choco upgrade notepadplusplus -y 
choco upgrade 7zip -y
choco upgrade imageglass -y

##Install FSLogix
choco upgrade fslogix -y -s='chocolatey'

#Install CSR Admin (SysAdmin) Tools
#choco upgrade winscp.install -y
#choco upgrade securecrt -y
#choco upgrade rdm -y
#choco upgrade vscode.install -y
#choco upgrade powershell-core -y
#choco upgrade python -y
#choco upgrade PowerBi -y
#choco upgrade gt-sccm-console -y


#Install Office365 Enterprise Apps Semi-Annual Channel Release
$o365ConfigPath = "\\gt-repo.ad.gatech.edu\configs$\WVD-General-Office365-Configuration.xml" 
choco upgrade office365proplus --params "/ConfigPath:$o365ConfigPath" -y

##Install OneDrive
choco upgrade microsoft-onedrive -y

#Install Teams
choco install microsoft-teams.install --install-arguments="'ALLUSERS=1'" -y

#Install Teams WebSocket
$websocket = "\\gt-repo\configs$\wvd-source-files\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"
msiexec /passive /i $websocket

#Install Licensed Apps
#choco upgrade fireeye -y --install-arguments='"INSTALLSERVICE=2"'
#choco upgrade qualysagent -y
choco upgrade adobeacrobat-fr -y --skip-virus-check

##Get all choco apps installed
choco list --l

##Disable Defender - Requires Reboot
#Uninstall-WindowsFeature 'Windows-Defender','Windows-Defender-GUI' -ErrorAction silentlycontinue
#Set-MpPreference -DisableRealtimeMonitoring $true
#New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

##Delete Desktop Icons
Remove-Item "c:\Users\*\Desktop\Firefox.lnk" -force
Remove-Item "c:\Users\*\Desktop\Google Chrome.lnk" -force
Remove-Item "c:\Users\*\Desktop\Microsoft Edge.lnk" -force
Remove-Item "c:\Users\*\Desktop\Adobe Acrobat DC.lnk" -force
Remove-Item "c:\Users\*\Desktop\ImageGlass.lnk" -force
Remove-Item "c:\Users\*\Desktop\Visual Studio Code.lnk" -force
Remove-Item "c:\Users\*\Desktop\Power BI Desktop.lnk" -force
Remove-Item "c:\Users\*\Desktop\WinSCP.lnk" -force
Remove-Item "c:\Users\*\Desktop\SecureCRT 8.7.lnk" -force

##Optimize Image

#Set Time to Eastern Time Zone
tzutil /s "Eastern Standard Time"
 
#Disable Auto-Updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

#TimeZone Redirection 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

#Disable Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

##Regedit to optimize Teams for WVD
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f

#Regedit to add in Web Socket Redirector
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector" /v "WebRTC Redirector Enabled" /t REG_DWORD /d 1 /f


#Get-Item - "\\gt-repo\configs$\wvd-source-files\Virtual-Desktop-Optimization-Tool-master" | Copy-Item "C:\Optimize"

#Files for Post Deployment
$localpath = "C:\Installs"
$remotepath = "\\gt-repo.ad.gatech.edu\configs$\wvd-source-files"

#Create C:\Installs
Write-Output "Creating Directory: " $localpath 
New-Item $localpath -ItemType Directory

#Copy Post Deploy Script to C:\installs
Write-Output "Copy Post Deployment Script to " $localpath
Get-Item "$remotepath\post-deploy.ps1" | Copy-Item -Destination $localpath

#Copy WVD Optimization Scripts to C:\Installs
Write-Output "Copy Windows Virtual desktop Optimization to " $localpath
Get-Item "$remotepath\Virtual-Desktop-Optimization-Tool-master.zip" | Copy-Item -Destination $localpath

#Expand WVD Optimization Files
Write-Output "Expand Zipped Files"
Expand-Archive $LocalPath\'Virtual-Desktop-Optimization-Tool-master.zip' -DestinationPath $localpath

#Start 1 Min Wait
Start-Sleep -Seconds 60

Write-Output "Cleanup files in " $localpath
Get-Item "$LocalPath\Virtual-Desktop-Optimization-Tool-master.zip" | Remove-Item -Force -Confirm:$false


#Reboot
& shutdown -r -t 300

#After Reboot - 
#SysPrep and ShutDown.
#C:\Windows\system32\sysprep\sysprep.exe /generalize /shutdown /oobe



