## Powershell Script for GT Virtual Workspace IMG
## Deploy Windows 10 MultiSession w/o Office
## Mount NetworkDrive, and Execute Script
## mfranklin7@gatech.edu
## updated Feb 2021

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\vlab-win10-nonpersistent.ps1'

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
choco upgrade vscode.install -y
#choco upgrade powershell-core -y
#choco upgrade python -y
#choco upgrade PowerBi -y
#choco upgrade winscp.install -y
#choco upgrade securecrt -y
#choco upgrade gt-sccm-console -y
#choco upgrade rdm -y

#Install Office365 Enterprise Apps Semi-Annual Channel Release
$o365ConfigPath = "\\gt-repo.ad.gatech.edu\configs$\VLAB-O365-Configuration.xml" 
choco upgrade office365proplus --params "/ConfigPath:$o365ConfigPath" -y

##Install OneDrive
choco upgrade microsoft-onedrive -y

#Install Teams
choco install microsoft-teams.install --install-arguments="'ALLUSERS=1'" -y

#Install Teams WebSocket
$websocket = "\\gt-repo\configs$\wvd-source-files\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"
msiexec /passive /i $websocket

#Install Licensed Apps
choco upgrade adobeacrobat-fr -y --skip-virus-check

##Get all choco apps installed
choco list --l

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

#Disable Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f

#Regedit to optimize Teams for WVD
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f

#Regedit to add in Web Socket Redirector
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector" /v "WebRTC Redirector Enabled" /t REG_DWORD /d 1 /f

#Files for Post Deployment
$localpath = "C:\Installs"
$remotepath = "\\gt-repo.ad.gatech.edu\configs$\vlab source files"

#Create C:\Installs
Write-Output "Creating Directory: " $localpath 
New-Item $localpath -ItemType Directory

#Copy Post Deploy Script to C:\installs
Write-Output "Copy Post Deployment Script to " $localpath
Get-Item "$remotepath\vlab-post-deploy.ps1" | Copy-Item -Destination $localpath

#Copy Citrix VDA to C:\Installs
Write-Output "Copy Citrix VDA to " $localpath
Get-Item "$remotepath\VDAWorkstationSetup_1912.exe" | Copy-Item -Destination $localpath

#Copy Citrix Optimizer to C:\Installs
Write-Output "Copy Windows Virtual desktop Optimization to " $localpath
Get-Item "$remotepath\Citrix Optimizer - v2.8.0.143.zip" | Copy-Item -Destination $localpath

#Expand Citrix Optimizer 
Write-Output "Expand Citrix Optimizer Files"
Expand-Archive $LocalPath\'Citrix Optimizer - v2.8.0.143.zip' -DestinationPath "$localpath\Citrix Optimizer - v2.8.0.143"

#Copy Nvid Drivers to C:\Installs
Write-Output "Copy Nvidia Drivers to " $localpath
Get-Item "$remotepath\nvid.zip" | Copy-Item -Destination $localpath

#Expand Nvid Drivers 
Write-Output "Expand Nvidia Zipped Files"
Expand-Archive $LocalPath\'nvid.zip' -DestinationPath "$localpath\"

#Copy WVD Optimization Scripts to C:\Installs
Write-Output "Copy Windows Virtual desktop Optimization to " $localpath
Get-Item "$remotepath\Virtual-Desktop-Optimization-Tool-master.zip" | Copy-Item -Destination $localpath

#Expand WVD Optimization Files
Write-Output "Expand Windows Optimization Files"
Expand-Archive $LocalPath\'Virtual-Desktop-Optimization-Tool-master.zip' -DestinationPath $localpath

#Start 1 Min Wait
Start-Sleep -Seconds 60

Write-Output "Cleanup Citrix Optimizer files in " $localpath
Get-Item "$LocalPath\Citrix Optimizer - v2.8.0.143.zip" | Remove-Item -Force -Confirm:$false

Write-Output "Cleanup Windows Optimization files in " $localpath
Get-Item "$LocalPath\Virtual-Desktop-Optimization-Tool-master.zip" | Remove-Item -Force -Confirm:$false

Write-Output "Cleanup Nvidia Files in " $localpath
Get-Item "$LocalPath\nvid.zip" | Remove-Item -Force -Confirm:$false


#Run this post deployment to optimize image and install endpoint agents

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & 'c:\installs\vlab-post-deploy.ps1'

$localpath = "C:\installs"

#Istall Nvidia Drivers  - must be extracted prior to installation
$userinput = $(Write-Host "Do you want to install nvidia driver? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    Write-Host -ForegroundColor Yellow "Installing Nvidia Driver"
    $install_args = "-passive -noreboot -noeula -nofinish -s"
    #Install 8.X version of driver
    $nvid = Start-Process -FilePath "$localpath\nvid\8.6\DisplayDriver\427.11\Win10_64\International\setup.exe" -ArgumentList $install_args -wait
    Wait-Process $nvid
}

#Install Citrix VDA
$userinput = $(Write-Host "Do you want to install Citrix VDA? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{
    Write-Host -ForegroundColor Yellow "Installing Citrix VDA"
    #Silently install VDA
    $vda = Start-Process -FilePath "$localpath\VDAWorkstationSetup_1912.exe" -ArgumentList '/controllers "coda-xd7-srv1.ad.gatech.edu coda-xd7-srv2.ad.gatech.edu" /noreboot /quiet /virtualmachine /enable_hdx_ports /enable_hdx_udp_ports /includeadditional "Citrix Supportability Tools","Machine Identity Service","Citrix User Profile Manager","Citrix User Profile Manager WMI Plugin" /exclude "Workspace Environment Management","Citrix Files for Outlook","Citrix Files for Windows","Citrix Personalization for App-V - VDA","Personal vDisk" /components vda /mastermcsimage' 
    Write-Host -ForegroundColor Yellow "Waiting on Citrix installer"
    Wait-Process $vda
}


#Upgrade all Choco Packages
$userinput = $(Write-Host "Do you want to update all choco packages? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Update all installed apps
    choco upgrade all -y
}

Write-Host -ForegroundColor DarkYellow "All agents and drivers installed."
$userinput = $(Write-Host "Do you want to continue with Cleanup? y/n " -ForegroundColor DarkYellow -NoNewline; Read-Host)
if ($userinput -ne 'y')
{exit}

Write-Host -ForegroundColor Magenta "clean as a whistle; proceed with cauction"


#Cleanup Windows temp files, similar to diskcleanup.exe
$userinput = $(Write-Host "Do you want to cleanup windows? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    # Delete not in-use files in locations C:\Windows\Temp and %temp%
    # Also sweep and delete *.tmp, *.etl, *.evtx, *.log, *.dmp, thumbcache*.db (not in use==not needed)
        Write-Verbose "Removing .tmp, .etl, .evtx, thumbcache*.db, *.log files not in use"
        Get-ChildItem -Path c:\ -Include *.tmp, *.dmp, *.etl, *.evtx, thumbcache*.db, *.log -File -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue

        # Delete "RetailDemo" content (if it exits)
        Write-Verbose "Removing Retail Demo content (if it exists)"
        Get-ChildItem -Path $env:ProgramData\Microsoft\Windows\RetailDemo\* -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -ErrorAction SilentlyContinue

        # Delete not in-use anything in the C:\Windows\Temp folder
        Write-Verbose "Removing all files not in use in $env:windir\TEMP"
        Remove-Item -Path $env:windir\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

        # Clear out Windows Error Reporting (WER) report archive folders
        Write-Verbose "Cleaning up WER report archive"
        Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportArchive\* -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportQueue\* -Recurse -Force -ErrorAction SilentlyContinue

        # Delete not in-use anything in your %temp% folder
        Write-Verbose "Removing files not in use in $env:TEMP directory"
        Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue

        # Clear out ALL visible Recycle Bins
        Write-Verbose "Clearing out ALL Recycle Bins"
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue

        # Clear out BranchCache cache
        Write-Verbose "Clearing BranchCache cache"
        Clear-BCCache -Force -ErrorAction SilentlyContinue
    }


#Delete Local User Account
$userinput = $(Write-Host "Do you want to delete local user account? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
{
    #NEED TO TEST VARIABLE 'dilbert'
    $username = $(Write-Host "Enter local user account name: " -ForegroundColor Yellow -NoNewline; Read-Host)
    Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $username } | Remove-CimInstance
}

#Delete C:\Installs
$userinput = $(Write-Host "Do you want to delete '$localpath'? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{

    #Wait for 10 minutes for script to finish installs to complete
    Write-Host -ForegroundColor Yellow "The folder '$localpath' will be deleted in 5 minutes."
    Start-Sleep -Seconds 300
    #delete local folder
    Get-ChildItem $localpath| Remove-Item -Recurse -Force -Confirm:$false
}



#reboot
$userinput = $(Write-Host "Do you want to reboot? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y') 
{ 
    Write-Host -ForegroundColor Yellow "Rebooting in 60 seconds."
    & shutdown -r -t 60
}



<#



###################################################

#Region Installers

#Silently install Nvidia Driver
$install_args = "-passive -noreboot -noeula -nofinish -s"
#Install 8.X version of driver
Start-Process -FilePath "C:\installs\nvid\8.6\DisplayDriver\427.11\Win10_64\International\setup.exe" -ArgumentList $install_args -wait
#Install 11.x version of driver
Start-Process -FilePath "C:\installs\nvid\11.3\DisplayDriver\452.77\Win10_64\International\setup.exe" -ArgumentList $install_args -wait

#Install Citrix VDA
#Silently install VDA
Start-Process -FilePath "C:\installs\VDAWorkstationSetup_1912.exe" -ArgumentList '/controllers "coda-xd7-srv1.ad.gatech.edu coda-xd7-srv2.ad.gatech.edu" /noreboot /quiet /virtualmachine /enable_hdx_ports /enable_hdx_udp_ports /includeadditional "Citrix Supportability Tools","Machine Identity Service","Citrix User Profile Manager","Citrix User Profile Manager WMI Plugin" /exclude "Workspace Environment Management","Citrix Files for Outlook","Citrix Files for Windows","Citrix Personalization for App-V - VDA","Personal vDisk" /components vda /mastermcsimage' 

#Choco install dependencies
choco upgrade vcredist2013 vcredist140 --yes --source='chocolatey' --ignoredependencies
#reboot
Write-Output "This Computer will reboot in 60 seconds" 
shutdown /r /t 60
#Choco install VDA
choco upgrade citrix-vda-workstation1912 --yes --source='https://repo.oit.gatech.edu/chococoe/' --ignoredependencies

#Update all installed apps
choco upgrade all -y

#Install EndPoint Agents.
#Choco install FireEye
choco upgrade fireeye -y --install-arguments='"INSTALLSERVICE=2"'
#Choco install Qualys
choco upgrade qualysagent -y

#EndRegion Installers

##########################################################

#Region OptimizeImage 

#set local folder
$localpath = "C:\Installs\Virtual-Desktop-Optimization-Tool-master"
#Virtual Desktop Team Optimization Script
Set-ExecutionPolicy Bypass -Scope Process -Force; & "$localpath\Win10_VirtualDesktop_Optimize.ps1"

#Citrix Optimizer
#Analyze Windows for Optimizations
Set-ExecutionPolicy Bypass -Scope Process -Force; & 'C:\installs\Citrix Optimizer - v2.8.0.143\CtxOptimizerEngine.ps1' -Analyze
#Execute Optimization for Windows 10 version 1909, create rollback file.
Set-ExecutionPolicy Bypass -Scope Process -Force; & 'C:\installs\Citrix Optimizer - v2.8.0.143\CtxOptimizerEngine.ps1'-Mode Execute -OutputXml C:\installs\Rollback.xml

#EndRegion OptimizeImage

############################################################

#Region Cleanup

#Cleanup - 
#Delete Local User Account 'dilbert'
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'dilbert' } | Remove-CimInstance

#Wait for 10 minutes for script to finish installs to complete
Write-Output " The C:\installs folder will be deleted in 10 minutes."
Start-Sleep -Seconds 600
#delete local folder
$localpath = "C:\Installs"
Get-ChildItem $localpath| Remove-Item -Recurse -Force -Confirm:$false

#EndRegion Cleanup



#>




<#



###################################################

#Region Installers

#Silently install Nvidia Driver
$install_args = "-passive -noreboot -noeula -nofinish -s"
#Install 8.X version of driver
Start-Process -FilePath "C:\installs\nvid\8.6\DisplayDriver\427.11\Win10_64\International\setup.exe" -ArgumentList $install_args -wait
#Install 11.x version of driver
Start-Process -FilePath "C:\installs\nvid\11.3\DisplayDriver\452.77\Win10_64\International\setup.exe" -ArgumentList $install_args -wait

#Install Citrix VDA
#Silently install VDA
Start-Process -FilePath "C:\installs\VDAWorkstationSetup_1912.exe" -ArgumentList '/controllers "coda-xd7-srv1.ad.gatech.edu coda-xd7-srv2.ad.gatech.edu" /noreboot /quiet /virtualmachine /enable_hdx_ports /enable_hdx_udp_ports /includeadditional "Citrix Supportability Tools","Machine Identity Service","Citrix User Profile Manager","Citrix User Profile Manager WMI Plugin" /exclude "Workspace Environment Management","Citrix Files for Outlook","Citrix Files for Windows","Citrix Personalization for App-V - VDA","Personal vDisk" /components vda /mastermcsimage' 

#Choco install dependencies
choco upgrade vcredist2013 vcredist140 --yes --source='chocolatey' --ignoredependencies
#reboot
Write-Output "This Computer will reboot in 60 seconds" 
shutdown /r /t 60
#Choco install VDA
choco upgrade citrix-vda-workstation1912 --yes --source='https://repo.oit.gatech.edu/chococoe/' --ignoredependencies

#Update all installed apps
choco upgrade all -y

#Install EndPoint Agents.
#Choco install FireEye
choco upgrade fireeye -y --install-arguments='"INSTALLSERVICE=2"'
#Choco install Qualys
choco upgrade qualysagent -y

#EndRegion Installers

##########################################################

#Region OptimizeImage 

#set local folder
$localpath = "C:\Installs\Virtual-Desktop-Optimization-Tool-master"
#Virtual Desktop Team Optimization Script
Set-ExecutionPolicy Bypass -Scope Process -Force; & "$localpath\Win10_VirtualDesktop_Optimize.ps1"

#Citrix Optimizer
#Analyze Windows for Optimizations
Set-ExecutionPolicy Bypass -Scope Process -Force; & 'C:\installs\Citrix Optimizer - v2.8.0.143\CtxOptimizerEngine.ps1' -Analyze
#Execute Optimization for Windows 10 version 1909, create rollback file.
Set-ExecutionPolicy Bypass -Scope Process -Force; & 'C:\installs\Citrix Optimizer - v2.8.0.143\CtxOptimizerEngine.ps1'-Mode Execute -OutputXml C:\installs\Rollback.xml

#EndRegion OptimizeImage

############################################################

#Region Cleanup

#Cleanup - 
#Delete Local User Account 'dilbert'
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'dilbert' } | Remove-CimInstance

#Wait for 10 minutes for script to finish installs to complete
Write-Output " The C:\installs folder will be deleted in 10 minutes."
Start-Sleep -Seconds 600
#delete local folder
$localpath = "C:\Installs"
Get-ChildItem $localpath| Remove-Item -Recurse -Force -Confirm:$false

#EndRegion Cleanup



#>

