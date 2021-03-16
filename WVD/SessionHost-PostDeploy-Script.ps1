#WVD Post Deployment Script

#command to call script: Set-ExecutionPolicy Bypass -Scope Process -Force; & 'c:\installs\post-deploy.ps1'


#Upgrade all Choco Packages
$userinput = $(Write-Host "Do you want to update all choco packages? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Update all installed apps
    choco upgrade all -y
}

#Istall FireEye
$userinput = $(Write-Host "Do you want to install FireEye? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Install FireEye
    choco upgrade fireeye -y --install-arguments='"INSTALLSERVICE=2"'
}


#Istall FireEye
$userinput = $(Write-Host "Do you want to install Qualys Agent? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #Install Qualys
    choco upgrade qualysagent -y
}

Write-Host -ForegroundColor DarkYellow "All agents and drivers installed."
$userinput = $(Write-Host "Do you want to continue with optimization? y/n " -ForegroundColor DarkYellow -NoNewline; Read-Host)
if ($userinput -ne 'y')
{exit}

Write-Host -ForegroundColor Magenta "proceed with cauction"


#Optimize Session Host
$userinput = $(Write-Host "Do you want to optimize windows? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{
    #set local folder
    $localpath = "C:\Installs\Virtual-Desktop-Optimization-Tool-master"

    #Run WVD Optimization Script
    Set-ExecutionPolicy Bypass -Scope Process -Force; & "$localpath\Win10_VirtualDesktop_Optimize.ps1"
}

#Delete C:\Installs
$userinput = $(Write-Host "Do you want to delete 'C:\installs'? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{

    #Wait for 10 minutes for script to finish installs to complete
    Write-Host -ForegroundColor Yellow " The C:\installs folder will be deleted in 5 minutes."
    Start-Sleep -Seconds 300
    #delete local folder
    $localpath = "C:\Installs"
    Get-ChildItem $localpath| Remove-Item -Recurse -Force -Confirm:$false
}



#reboot
$userinput = $(Write-Host "Do you want to reboot? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y') 
{ 
    Write-Host -ForegroundColor Yellow "Rebooting in 60 seconds."
    & shutdown -r -t 60
}
