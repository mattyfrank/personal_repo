#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$erroractionpreference = "SilentlyContinue"
$ITAMServer = "itam.oit.gatech.edu"

#################################################################################################
#Test to see if gtinventory id exists by looking to see if entry id exists. If it does not exist create the entry.
# If the entry already exists, the existing entry will be updated
function createitamentry($gtinventory)
{
$uri = "https://$ITAMServer/lifecycle/records.xml?query=gtinventory%3D%22$gtinventory%22"
$stream = $webcl.downloadstring($uri)
 [xml]$itamxml = $stream
 $itamfqdnarray = $itamxml.records.record |Select-Object id

 foreach ($itamobj in $itamfqdnarray){
   if ($itamobj.id -eq $null){Write-Host -ForegroundColor green "The ITAM Entry will be created."}
   if ($itamobj.id -eq $null){$uri = "https://$ITAMServer/lifecycle/records.xml"}
   if ($itamobj.id -eq $null){$NewItam = "record[gtinventory]=$gtinventory"}
   if ($itamobj.id -eq $null){$webcl.UploadString($uri,$NewItam)}
   if ($itamobj.id -ne $null){Write-Host -ForegroundColor red "The ITAM Entry already exists, the existing entry will be updated."}    
 }
}




if ($cred -eq $null){$cred = Get-Credential}
$gtinventory = Read-Host "Enter the GTInventory"
$assetowner = Read-Host "Enter the asset owner"


#Create webclient object
$webcl= New-Object System.Net.Webclient             
$webcl.credentials = $cred

#Create New ITAM Entry
createitamentry($gtinventory)

#Define Search uri
$uri = "https://$ITAMServer/lifecycle/records.xml?query=gtinventory%3D%22$gtinventory%22"

#Get Current Date
$date = get-date -uformat "%Y-%m-%d"


######################################################################################################################################################
#copied from itam module
#############################################################################
function get-cpu($computer)
{
$colcpu = Get-WmiObject -class win32_processor -computername $computer
$count = 0
$cpucore = 0
foreach ($objcpu in $colcpu){
$count = $count +1
$cpuspeed = $objcpu.maxclockspeed
$cpucore = $objcpu.NumberOfCores + $cpucore
}
if($cpucore -eq 0) {$cpucore=$count}
$strcpu =  $cpuspeed.ToString() + "x" + $cpucore.ToString()

$strcpuname = $objcpu.name
$arch = $objcpu.architecture
$arch = Switch ($arch)
{
0 {"x86"}
1 {"MIPS"}
2 {"Alpha"}
3 {"PowerPC"}
6 {"Itanium-based systems"}
9 {"x64"}
}

$hashcpuinfo = @{"xtarget" = $strcpuname;"arch" = $arch;"cpu" = $strcpu}
$hashcpuinfo

Clear-Variable colcpu
Clear-Variable hashcpuinfo
}

###########################################################################
function get-localadmins($computer)
{
$arraymembers = @()

#create an object bound to the administrators group
$group = New-Object System.DirectoryServices.DirectoryEntry("WinNT://$computer/administrators")

#using the system.directoryservices invoke method, call the members method to create a collection of members. Members are returned as adsi objects.
$members = $group.Invoke("members")

#cycle through the $members collection and use the InvokeMember method to retrieve the adspath property. 
#Reference "Invoking ADSI Properties" http://msdn.microsoft.com/en-us/library/ms180895(v=vs.90).aspx#Y101
foreach ($obj in $members){
$type=$obj.GetType()
$member = $type.InvokeMember("adspath",'Getproperty',$null,$obj,$null)
$member = $member.Replace("WinNT://","")
$arraymembers = $arraymembers + $member
}
$arraymembers

Clear-Variable arraymembers
Clear-Variable member
Clear-Variable type
Clear-Variable group
Clear-Variable computer
}

###########################################################################
function get-computerinfo($computer)
{
$objcompsys = Get-WmiObject -class Win32_ComputerSystem -computername $computer
$computerName = $objcompsys.Name
$ComputerDomain = $objcompsys.Domain
$fqdn =$computerName + "." + $ComputerDomain
$ComputerModel = $objcompsys.model
$ComputerModel = $ComputerModel.ToLower()
if($ComputerModel -eq "vmware virtual platform"){
$ComputerModel = "vmware"}
elseif ($ComputerModel -eq "virtual machine"){
$ComputerModel = "hyper-v"}
else{}
$ComputerModel = $ComputerModel.Replace("(tm)","")
$manufacturer = $objcompsys.manufacturer
$hashcomputerinfo = @{"cn" = $computerName.ToLower();"fqdn" = $fqdn.ToLower(); "model" = $computermodel;"manufacturer" = $manufacturer.ToLower()}
$hashcomputerinfo
}

###########################################################################
function get-biosinfo($computer)
{
$objbios = Get-WmiObject -class win32_bios -computername $computer
$ComputerBios = $objbios.serialnumber
$ComputerBios = $ComputerBios.tolower()
$ComputerBios
}

###########################################################################
function get-osinfo($computer)
{
$tm = [char]174
$tm = $tm.ToString()
$objopersys = Get-WmiObject -class Win32_OperatingSystem -computername $computer
$InstallDate =[System.Management.ManagementDateTimeConverter]::todatetime($objopersys.installdate)
$InstallDate = $InstallDate.Month.ToString() + "/" + $InstallDate.Day.ToString() + "/" + $InstallDate.Year.ToString()
$OSSystemCaption =  $objopersys.caption
$OSSystemCaption =  $OSSystemCaption.Replace($tm,"")
$OSSystemCaption = $OSSystemCaption.ToLower()
$OSSystemCaption = $OSSystemCaption.Replace("(r)","")
$OSArchitecture = $objopersys.osarchitecture
$OSArchitecture = $OSArchitecture.Replace("-bit", "")
$LastBoottime = [System.Management.ManagementDateTimeConverter]::todatetime($objopersys.lastbootuptime)
$LastBoottime = $LastBoottime.Month.ToString() + "/" + $LastBoottime.Day.ToString() + "/" + $LastBoottime.Year.ToString()
$hashosinfo = @{"caption" = $OSSystemCaption;"version" = $objopersys.version; "servicepack" = $objopersys.servicepackmajorversion;"osinstalldate" = $InstallDate;"osarchitecture" = $OSArchitecture;"lastbootuptime" = $LastBoottime}
$hashosinfo
}

###########################################################################
function get-ram($computer)
{
$colphysmem = Get-WmiObject -class cim_physicalmemory -computername $computer
foreach ($objphysmem in $colphysmem) {
    $TotalRam = $objphysmem.Capacity + $TotalRam
    
    }
    $TotalRam = $TotalRam / 1mb
    $TotalRam
}

function get-ipinfo($computer)
{
$colnet = Get-WmiObject -class Win32_NetworkAdapterConfiguration -computername $computer
#get ipv4 addresses
$colipv4 = $null
$colipv4 = @()
foreach ($objnet in $colnet){
foreach ($objip in $objnet.ipaddress){
if ($objip -like "*.*"){
$colipv4 = $colipv4 + $objip.ToString()
}
}
}
#get ipv6 addresses
$colipv6 = $null
$colipv6 = @()
foreach ($objnet in $colnet){
foreach ($objip in $objnet.ipaddress){
if ($objip -like "*:*"){
$colipv6 = $colipv6 + $objip.ToString()
}
}
}
$colipv4
$colipv6
}

###########################################################################
function get-macaddr($computer)
{
$array=@()
$coladapter =  Get-WmiObject win32_networkadapter -computername $computer | Where-Object {($_.servicename -ne "asyncmac") -and ($_.servicename -ne "RasPppoe") -and ($_.servicename -ne "PptpMiniport") -and ($_.servicename -ne "tunmp") -and ($_.servicename -ne "FirehkMP")}
foreach ($adapter in $coladapter){foreach ($mac in $adapter.macaddress){
if ($mac -ne $null){
$array += $mac.ToLower()}
}}
$array
}

###########################################################################
function get-lastpatchdate($computer)
{
$qfearray = Get-WmiObject win32_quickfixengineering -ComputerName $computer


$arrdate =@()
$arrdate = foreach ($obj in $qfearray){$obj.installedon}
$arrdate = $arrdate|Sort-Object -Descending
$lastpatch = $arrdate.GetValue(0)
if ($lastpatch -ne $null){
$lastpatchdate = $lastpatch.Month.ToString() + "/" + $lastpatch.Day.ToString() + "/" + $lastpatch.Year.ToString()}
$lastpatchdate
}



function mlist($mlistid){
#get itam info from remote machine
$computer="localhost"
$compsys = get-computerinfo $computer
$uri = "https://$ITAMServer/lifecycle/records/$mlistid.xml" 

if ($compsys -ne $null){
$colcpu = get-cpu $computer
$bios = get-biosinfo $computer
$opersys = get-osinfo $computer
$physmem = get-ram $computer
$colnet = get-ipinfo $computer
$ethernet = @()
$ethernet = get-macaddr $computer
$last_patched = get-lastpatchdate $computer
$colipv4 = $colnet | Where-Object {!($_ -like "*:*")}
$colipv6 = $colnet | Where-Object {$_ -like "*:*"}

#add systeminfo into a namevaluecollection
$namevalcoll=new-object -typename system.collections.specialized.namevaluecollection;
#add to req. fields to purchase process then transition
$namevalcoll.Add("record[asset_owner]",$assetowner)
$namevalcoll.Add("record[equipment_type]","SERVER")
$namevalcoll.Add("record[acquisition_date]",$opersys.osinstalldate)
$namevalcoll.Add("record[cost]","0")
$namevalcoll.Add("record[state_id]","4be96a093afb22d55900000c")
$stream = $webcl.Uploadvalues($uri,"put",$namevalcoll)

$namevalcoll=new-object -typename system.collections.specialized.namevaluecollection;
#add to req. fields to physical installation then transition to burn in
$namevalcoll.Add("record[building]","vm")
$namevalcoll.Add("record[console_access]","vm")
$namevalcoll.Add("record[state_id]","4be96a0a3afb22d559000016")
$stream = $webcl.Uploadvalues($uri,"put",$namevalcoll)


#test if computer model is valid
$namevalcoll=new-object -typename system.collections.specialized.namevaluecollection;
#add to req. fields to  burn in then transition to OS Provisioning
if (!($compsys.model -like "*xxx00*")){
$namevalcoll.Add("record[model]",$compsys.model)
}
$namevalcoll.Add("record[state_id]","4be96a0a3afb22d559000020")
$stream = $webcl.Uploadvalues($uri,"put",$namevalcoll)

$namevalcoll=new-object -typename system.collections.specialized.namevaluecollection;
#add to req. fields to OS Provisioning
$namevalcoll.Add("record[cn]",$compsys.cn)
$namevalcoll.Add("record[fqdn]",$compsys.fqdn)
$namevalcoll.Add("record[osname]","windows")
$namevalcoll.Add("record[osversion]",$opersys.version)
$namevalcoll.Add("record[splevel]",$opersys.servicepack)
$namevalcoll.Add("record[osdist]",$opersys.caption)

foreach ($mac in $ethernet){
$namevalcoll.Add("record[ethernet]",$mac)
}
#if serial is valid add to namevalcoll
if (!($bios -eq "") -and !($bios -eq $null) -and !($bios -like "xxxxx*") -and !($bios.Contains("o.e.m")) -and !($bios -like "chassis*")){
$namevalcoll.Add("record[serialnumber]",$bios)
}
if ($opersys.osarchitecture -ne $null){
$namevalcoll.Add("record[isabits]",$opersys.osarchitecture)}
$namevalcoll.Add("record[root]","rdp")
if ($colcpu.cpu -ne $null){
$namevalcoll.Add("record[cpu]",$colcpu.cpu)}
$namevalcoll.Add("record[memory]",$physmem)

$namevalcoll.Add("record[osinstalldate]",$opersys.osinstalldate)
$namevalcoll.Add("record[last_patched]",$last_patched)
foreach ($ipv4 in $colipv4){
$namevalcoll.Add("record[ipaddr]",$ipv4)}
foreach ($ipv6 in $colipv6){
$namevalcoll.Add("record[ipv6addr]",$ipv6)}
$namevalcoll.Add("record[xtarget]",$colcpu.xtarget)
$namevalcoll.Add("record[arch]",$colcpu.arch)
$namevalcoll.Add("record[backups]","UNKNOWN")
$namevalcoll.Add("record[pwstore]","GTAD")

#upload info into itam
$stream = $webcl.Uploadvalues($uri,"put",$namevalcoll)
$streamarr = $stream.split("`n")
$streamarr

#log failed upload
if ($streamarr.count -ne $null){
Write-Host -ForegroundColor red "Upload of data into ITAM failed"
}



}


else{
Write-Host -ForegroundColor red "Upload of data into ITAM failed"
}
}



#Get itam id from itam
$stream = $webcl.downloadstring($uri)
 [xml]$itamxml = $stream
 $itamfqdnarray = $itamxml.records.record |Select-Object id


 foreach ($itamobj in $itamfqdnarray){
  mlist $itamobj.id
 }
 
 
Write-Host -ForegroundColor green "Information Loaded into ITAM"





# SIG # Begin signature block
# MIIJfQYJKoZIhvcNAQcCoIIJbjCCCWoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEifUA3uW1ClN52e8wj4FVICL
# H+WgggXBMIIFvTCCBKWgAwIBAgICBXowDQYJKoZIhvcNAQEFBQAwfjELMAkGA1UE
# BhMCVVMxEDAOBgNVBAgTB0dlb3JnaWExEDAOBgNVBAcTB0F0bGFudGExKDAmBgNV
# BAoTH0dlb3JnaWEgSW5zdGl0dXRlIG9mIFRlY2hub2xvZ3kxITAfBgNVBAMTGEdl
# b3JnaWEgVGVjaCBTZXJ2ZXIgUm9vdDAeFw0xMTAzMjIxNTE3MjNaFw0xNjAzMjEx
# OTE3MjNaMIGFMQswCQYDVQQGEwJVUzELMAkGA1UECAwCR0ExDDAKBgNVBAcMA0FU
# TDEoMCYGA1UECgwfR2VvcmdpYSBJbnN0aXR1dGUgb2YgVGVjaG5vbG9neTEMMAoG
# A1UECwwDT0lUMSMwIQYDVQQDDBpPSVQgUE9TSCBDb2RlIFNpZ25pbmcgQ2VydDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANLrdyUl3Z2vq/RN31r80LCn
# jPckXREyY8cUQanNINmFVN1pXnyO5OyTJOzfHs6UBIsZw60ZSaWJO034xy88x+Ct
# 8cKABF+5jOdECsBm4n6GG3DYAUEUpkxZHTWJ54oTHQ4OT3vUYq7R4mvvKlLre/+J
# 3RQdN99oGldF9UKZOo5YkP9DtjM4WmwXWlAkPKIGe2RRDfCibBOYKWO/QPo8GO5l
# 6ihHuFs4iixhjTN3MpUGc38p76RuWTuuUAfntFsELUezooDG/jwOyZZhjPweSxoB
# dMmROjQZ78NMSeoHkFJSZk+TRCVaz/xY3FKZu3c9TTIkt2Dxe4DkbcoDmOUvGvSP
# 55gc8gZEnYr+BFvJkwi6BSBcKv8WQYOM6FuK2QCVk0wM5TixYh3jchvUVsRXnfL2
# bt4zcB+uNeS1HyUBiIBwZoS0jN9Wv55h6mxY1Ha2q1fnSw68yig84OEdZq7JDLvM
# 9DBhAMQS/7YlCqc/HIobzwbGebjfEM+2hTAloOQKl9sgMCDtRei0OKomO1jmeyOC
# JyAT5eHuqEYu174pLQ9vj5vm1+fxvHYri6QqmeolT8yk5+2bdMLqY8Rk1fLe6w3l
# aiSSrafuPi+KKQlRE1ztJi/kw1mSxo2gMSTqMmV1wRODroDigqHXK1Hfedc3fwro
# ZWOGsKcWLRmjUacAKz7TAgMBAAGjggE7MIIBNzAJBgNVHRMEAjAAMBEGCWCGSAGG
# +EIBAQQEAwIEEDALBgNVHQ8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwKQYJ
# YIZIAYb4QgENBBwWGk9iamVjdCBTaWduaW5nIENlcnRpZmljYXRlMB0GA1UdDgQW
# BBRk9Y91vgW4jt1d1cz1swrSFMQ9ujCBqgYDVR0jBIGiMIGfgBStLJ10SAopLhva
# YseVLXJRwLDKVaGBg6SBgDB+MQswCQYDVQQGEwJVUzEQMA4GA1UECBMHR2Vvcmdp
# YTEQMA4GA1UEBxMHQXRsYW50YTEoMCYGA1UEChMfR2VvcmdpYSBJbnN0aXR1dGUg
# b2YgVGVjaG5vbG9neTEhMB8GA1UEAxMYR2VvcmdpYSBUZWNoIFNlcnZlciBSb290
# ggEAMA0GCSqGSIb3DQEBBQUAA4IBAQAqi7FPjRO/La/FsdELA9Lh4FQauu8bm54G
# I6SCIdwtT0NPMJHgbRZA83GGS75bH2NyFX3aNdbEDNlI1oLGO6Z0AAK4PXgmJIvT
# 77ANCJpjXvbT3xBwPDRUIROtZHjGP7rRXCTTXLfnfFye8ogfdodd3yGzxCnzxfO0
# drrCUFBtQC8Nqcf+oDOE+npYl9lKECx6WyW5otuWUG6JhDX1c0uR9qOP3F8uQoTk
# PjAsUhAJo0FerH9Iri0Vz967cM1pO8p+KRBExFxnkEszjohCcvEzQlFlke3AyCaE
# ShXloewmiXaI4+HrsqQzlb7rxbtB0uCEYl4ZnzQ1NZGd4jqPtp8QMYIDJjCCAyIC
# AQEwgYQwfjELMAkGA1UEBhMCVVMxEDAOBgNVBAgTB0dlb3JnaWExEDAOBgNVBAcT
# B0F0bGFudGExKDAmBgNVBAoTH0dlb3JnaWEgSW5zdGl0dXRlIG9mIFRlY2hub2xv
# Z3kxITAfBgNVBAMTGEdlb3JnaWEgVGVjaCBTZXJ2ZXIgUm9vdAICBXowCQYFKw4D
# AhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZI
# hvcNAQkEMRYEFAGb1sTIR7C2pXUYfdYqodlE3uM9MA0GCSqGSIb3DQEBAQUABIIC
# ADM7UDXJQ9c/vDSMubg1yKrMOaE2kSf8mF8uZYSpAanxTHkPVsV5aiW15Mt2YhEY
# 4F19xFlUf5ZAbAUfmSvG/Qofii8FWJ7ThwMbhsii/oYh2b88RgzCI0f4N4CqDKyb
# outrxwyoknvWc10W+LETsrGraridrQua0WSHzUeUJ1DteA1+M/CvKtMyHHtXXnMz
# Z1l+nfiw6+IoO9xxVtWyK3qulOi7/Pe1wsOe9mvjG5vD/iaAdIlwinwldcKCVRzy
# ZObP/ezF2gaqcOuARqDB0MgQeXOJDLRg1SvjLf+BBmZOJZjmoSiUGQ+6QDyfM5yk
# ncgMQHyakBvp6r8BLRjv41s4B2UJH22ucbO9oA18b08yBITdm/rCFjDJnLWorwOY
# Zi2865Ff23WfoOt3EgcLr+yWKvhwdCqRj2ULmxbTRaUFdbG/qF22nE3mR7bO8+E+
# lfAaKAOsQxjYXbkLaJAiQ2dv7G2zNDwVrOOhf07EyBwBjH42knYHPW/IGpHPF7Jo
# j8I1kgbAIB9jJE8S07A9h4GoGau4lyaU63Y0piNPIrM71ano0BSfNlvl92Fvh3uf
# cpbT37bmjfoWOEAyzaERqJArTCdexPr1rHZhQKFFgmr8sjT57+kdqrrDWCZXXkjC
# OhpN3OSCA39b4/OEvgne1LWxzK07dziYLt4KNR1FPg8D
# SIG # End signature block
