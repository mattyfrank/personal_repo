#Setup Citrix Master Image. 
#mfranklin7 02-2021

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & '\\gt-repo.ad.gatech.edu\configs$\vlab source files\bcdc-vlab-img-setup.ps1'

#Create directories
$localpath = "C:\Installs"
$remotepath = "\\gt-repo.ad.gatech.edu\configs$\vlab source files"

  
#Setup logging
If(!(Test-Path $localpath))
{
  Write-Output "Creating Directory: $localpath "
  New-Item $localpath -ItemType Directory
}

#Start Logging
Start-Transcript -Path "$localpath\log.txt"


#Region CopyFiles

#Copy Expand Partition Script to C:\installs
Write-Output "Copy Master-Image Script to $localpath "
Get-Item "$remotepath\Expand-Partition.ps1" | Copy-Item -Destination $localpath

#Copy Citrix Optimizer to C:\Installs
$CitrixOptimizer = "Citrix Optimizer - v2.8.0.143"
Write-Output "Copying $CitrixOptimizer to $localpath"
Get-Item "$remotepath\$CitrixOptimizer.zip" | Copy-Item -Destination $localpath
#Expand the zip
Write-Output "Expanding Citrix Optimizer Files"
Expand-Archive "$LocalPath\$CitrixOptimizer.zip" -DestinationPath "$localpath\$CitrixOptimizer"
#Delete the zip
Write-Output "Deleting '$CitrixOptimizer.zip' from $localpath"
Start-Sleep -Seconds 1
Get-Item "$LocalPath\$CitrixOptimizer.zip" | Remove-Item -Force -Confirm:$false

#Copy WVD Optimization Scripts to C:\Installs
$WindowsOptimization = "Virtual-Desktop-Optimization-Tool-master"
Write-Output "Copying $WindowsOptimization to $localpath "
Get-Item "$remotepath\$WindowsOptimization.zip" | Copy-Item -Destination $localpath
#Expand WVD Optimization Files
Write-Output "Expanding $WindowsOptimization Zipped Files"
Expand-Archive "$LocalPath\$WindowsOptimization.zip" -DestinationPath $localpath
#Delete the Optimization Zip
Write-Output "Deleting $WindowsOptimization in $localpath"
Start-Sleep -Seconds 1
Get-Item "$LocalPath\$WindowsOptimization.zip" | Remove-Item -Force -Confirm:$false

#EndRegion CopyFiles


#Prompt user to expand partition
$userinput = $(Write-Host "Do you want to expand the C:\ partition y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    # Get Volume C size and then resize the volume
    $drive_letter = "C"
    $size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
    Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax
}

#Region InstallNvidia

#Prompt for different versions like 8 and 11? 

$NvidiaZip = "nvid.zip"

#Istall Nvidia Drivers  - must be extracted prior to installation
$userinput = $(Write-Host "Do you want to install nvidia drivers? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Copy Nvid Drivers to C:\Installs
    Write-Output "Copying $NvidiaZip to $localpath "
    Get-Item "$remotepath\$NvidiaZip" | Copy-Item -Destination $localpath
    Start-Sleep -seconds 1
    
    #Expand Nvid Drivers 
    Write-Output "Expanding $NvidiaZip Files"
    Expand-Archive "$LocalPath\$NvidiaZip" -DestinationPath "$localpath"
    Start-Sleep -seconds 1

    #Delete Nvidia.zip
    Write-Output "Deleting $NvidiaZip in  $localpath"
    Start-Sleep -Seconds 1
    Get-Item "$LocalPath\$NvidiaZip" | Remove-Item -Force -Confirm:$false
    
    Write-Host -ForegroundColor Yellow "Installing Nvidia Driver"
    $install_args = "-passive -noreboot -noeula -nofinish -s"
    
    #Install 8.X version of driver
    Start-Process -FilePath "$localpath\nvid\8.6\DisplayDriver\427.11\Win10_64\International\setup.exe" -ArgumentList $install_args -wait
    
    #Install 11.x Version of driver
    #Start-Process -FilePath "$localpath\nvid\11.3\DisplayDriver\452.77\Win10_64\International\setup.exe" -ArgumentList $install_args -wait

    start-sleep -seconds 1

    #Delete Nvid install files
    Get-Item "$localpath\nvid" | Remove-Item -Recurse -Force -Confirm:$false
}

#EndRegion InstallNvidia


#Region InstallCitrixVDA

$CitrixVDA = "VDAWorkstationSetup_1912.exe"
#Install Citrix VDA
$userinput = $(Write-Host "Do you want to install $CitrixVDA ? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{
    #Copy Citrix VDA to C:\Installs
    Write-Output "Copying $CitrixVDA to $localpath"
    Get-Item "$remotepath\$CitrixVDA" | Copy-Item -Destination $localpath
    
    Start-Sleep -Seconds 1
    Write-Host -ForegroundColor Yellow "Installing Citrix VDA"
    
    #Silently install VDA
    Start-Process -Wait -FilePath "$localpath\$CitrixVDA" -ArgumentList '/controllers "bcdc-xd7-srv2.ad.gatech.edu bcdc-xd7-srv3.ad.gatech.edu" /noreboot /quiet /virtualmachine /enable_hdx_ports /enable_hdx_udp_ports /includeadditional "Citrix Supportability Tools","Machine Identity Service","Citrix User Profile Manager","Citrix User Profile Manager WMI Plugin" /exclude "Workspace Environment Management","Citrix Files for Outlook","Citrix Files for Windows","Citrix Personalization for App-V - VDA","Personal vDisk" /components vda /mastermcsimage' 
    Write-Host -ForegroundColor Yellow "Waiting on $CitrixVDA installer to complete"
    Start-Sleep -Seconds 60

    #Delete Citrix VDA installer
    Get-Item "$localpath\$CitrixVDA" | Remove-Item -Force -Confirm:$false

}

#EndRegion InstallCitrixVDA


#Region InstallFSLogix

$fslogix = "FSLogixAppsSetup.exe"

#Copy FSlogix to C:\Installs
#Istall FSLogix
$userinput = $(Write-Host "Do you want to install $fslogix ? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    Write-Output "Copy FSLogix to $localpath"
    Get-Item "$remotepath\$fslogix" | Copy-Item -Destination $localpath
    Write-Host -ForegroundColor Yellow "Installing $fslogix"
    $install_args = "/install /quiet /norestart"
    Start-Process -FilePath "$localpath\$fslogix" -ArgumentList $install_args -wait
    Start-Sleep -Seconds 1
    #Delte FSlogix Installer
    Get-Item  -Path "$localpath\$fslogix" | Remove-Item -Force -Confirm:$false
}

#EndRegion InstallFSLogix


#Region InstallChoco

$userinput = $(Write-Host "Do you want to install chocolatey? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Install chocolatey
    & "\\gt-repo.ad.gatech.edu\configs$\InstallChocolatey.ps1"
    choco upgrade chocolatey -y
    choco upgrade chocolatey-core.extension -y

}

#EndRegion InstallChoco

#reboot
$userinput = $(Write-Host "Do you want to 'dsregcmd /leave' ? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y') 
{ 
    & dsregcmd /leave
}


#reboot
$userinput = $(Write-Host "Do you want to reboot? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y') 
{ 
    Write-Host -ForegroundColor Yellow "Rebooting in 60 seconds."
    & shutdown -r -t 60
}


#Region CleanupImage

Write-Host -ForegroundColor Magenta "All agents and drivers installed."
$userinput = $(Write-Host "Do you want to begin cleanup tasks? y/n " -ForegroundColor Green -NoNewline; Read-Host)
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
    Write-Host -ForegroundColor Green "Deleting $username"
    Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $username } | Remove-CimInstance
}

#Delete C:\Installs
$userinput = $(Write-Host "Do you want to delete '$localpath'? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{

    #Wait for 10 minutes for script to finish installs to complete
    Write-Host -ForegroundColor Magenta "The folder '$localpath' will be deleted in 5 minutes."
    Start-Sleep -Seconds 3
    #delete local folder
    Get-ChildItem $localpath| Remove-Item -Recurse -Force -Confirm:$false
}

#EndRegion CleanupImage

Stop-Transcript


