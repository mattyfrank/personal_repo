$erroractionpreference = "SilentlyContinue"

Import-module activedirectory


$computer = "LocalHost" 
$namespace = "root\CIMV2" 
$colproc = Get-WmiObject -class cim_processor -computername $computer -namespace $namespace
$objcompsys = Get-WmiObject -class Win32_ComputerSystem -computername $computer -namespace $namespace
$objbios = Get-WmiObject win32_bios -computername $computer -namespace $namespace
$objopersys = Get-WmiObject -class Win32_OperatingSystem -computername $computer -namespace $namespace
$colphysmem = Get-WmiObject cim_physicalmemory -computername $computer -namespace $namespace


foreach ($objproc in $colproc){
$procspeed = $objproc.maxclockspeed
$proccore = $objproc.NumberOfCores + $proccore
}

$computerName = $objcompsys.Name
$ComputerDomain = $objcompsys.Domain
$fqdn =$computerName + "." + $ComputerDomain
$dn = Get-ADComputer $computername
$ComputerModel = $objcompsys.model
$Computermanufacturer = $objcompsys.manufacturer
$ComputerBios = $objbios.serialnumber
$OSSystemCaption = $objopersys.caption
$OSSystemVersion = $objopersys.version
$OSSystemSpLevel = $objopersys.servicepackmajorversion
$OSInstallDate =[System.Management.ManagementDateTimeConverter]::todatetime($objopersys.installdate)
$OSSystemDevice = $objopersys.systemdevice
$OSSystemDirectory = $objopersys.systemdirectory
$OSSystemDrive = $objopersys.systemdrive
$OSSystemLastBootupTime = [System.Management.ManagementDateTimeConverter]::todatetime($objopersys.lastbootuptime)
$OSSystemOSArchitecture = $objopersys.osarchitecture

foreach ($objphysmem in $colphysmem) {
    $TotalRam = $objphysmem.Capacity + $TotalRam
    
    }
    $TotalRam = $TotalRam / 1mb
    #$TotalRam = [System.Math]::Round($TotalRam)

$colws = get-process
foreach ($objws in $colws) {$wscalc = $wscalc + $objws.ws}
$wscalc = $wscalc/1mb
$wscalc = [System.Math]::Round($wscalc)

$colService = get-service | Where-Object {$_.status -eq "Running"} |ForEach-Object {$_.DisplayName} 



#Modify Variables for Writing

$strHostName = "cn: " + $computername.ToLower()
$strFQDN = "fqdn: " + $FQDN.ToLower()
$strdn = "adobject: " + $dn.DistinguishedName
$strOSName = "osname: windows"
$strdn = $strdn.tolower()
$strOSSystemVersion = "osversion: " + $OSSystemVersion.ToLower()
$strOSSplevel = "splevel: " + $OSSystemSpLevel
$strOSSystemDist = "osdist: " + $OSSystemCaption.ToLower()
$strComputerModel = "model: " + $ComputerModel.ToLower()
$strRoot = "root: rdp"
$strproc = "cpu: " + $procspeed + "x" + $proccore 
$strIntalledRam = "memory: " + $TotalRam
$strBios = "serialnumber: " + $ComputerBios.ToLower()


$strOSSystemOSArchitecture = "isabits: " + $OSSystemOSArchitecture.Replace("-bit", "")
$strTotalMemoryWorkingset = "Memory - Total Working Set: " + $wscalc 
$strOSSystemLastBootupTime = "Last Bootup Time: " + $OSSystemLastBootupTime
$strOSInstallDate = "Install Date: " + $OSInstallDate
$strOSSystemDevice = "SystemDevice: " + $OSSystemDevice.ToLower()
$strOSSystemDirectory = "System Directory: " + $OSSystemDirectory.ToLower()
$strOSSystemDrive = "System Drive: " + $OSSystemDrive.ToLower() 

#Write Output to file
$filename = $computername + ".txt"


Set-Content $filename $strHostName
Add-Content $filename $strFQDN
Add-Content $filename $strdn
Add-Content $filename $strOSName
Add-Content $filename $strOSSystemVersion
Add-Content $filename $strOSSplevel 
Add-Content $filename $strOSSystemDist
Add-Content $filename $strOSSystemOSArchitecture 
Add-Content $filename $strproc
Add-Content $filename $strIntalledRam
Add-Content $filename $strComputerModel 
Add-Content $filename $strRoot
Add-Content $filename $strBios
Add-Content $filename $strOSInstallDate 
Add-Content $filename $strOSSystemDevice
Add-Content $filename $strOSSystemDirectory 
Add-Content $filename $strOSSystemDrive 
Add-Content $filename $strOSSystemLastBootupTime 

Add-Content $filename $strTotalMemoryWorkingset




Clear-Variable -name strHostName
Clear-Variable -name strFQDN
Clear-Variable -name TotalRam
Clear-Variable -name strOSInstallDate 
Clear-Variable -name strOSSystemDevice
Clear-Variable -name strOSSystemDirectory 
Clear-Variable -name strOSSystemDrive 
Clear-Variable -name strOSSystemLastBootupTime 
Clear-Variable -name strOSSystemOSArchitecture 
Clear-Variable -name computername
Clear-Variable -name FQDN
Clear-Variable -name OSInstallDate
Clear-Variable -name OSSystemDevice
Clear-Variable -name OSSystemDirectory
Clear-Variable -name OSSystemDrive 
Clear-Variable -name OSSystemLastBootupTime
Clear-Variable -name OSSystemOSArchitecture
Clear-Variable -name wscalc
Clear-Variable -name strTotalMemoryWorkingset
Clear-Variable -name proccore