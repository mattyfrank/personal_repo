#To Disable Set-AzureADDevice -AccountEnabled
#To Delete Remove-AzureADDevice
#AAD_Tenant_ID="482198bb-ae7b-4b25-8b7a-6d7f32faa083"
#Subscription_ID="c1835977-39e7-4415-a092-a77866f5afb8"


[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter()]
    [string]
    $Path = "C:\StaleDevices",

    [Parameter()]
    [string]
    $logpath = "$Path\Logs",

    [Parameter()]
    [string]
    $logfile = "$Path\Logs\Stale-Devices-$(get-date -f yyyy-MM-dd-HH.mm).txt",

    [Parameter()]
    [string]
    $reportpath = "$Path\Reports"

    )

 #Setup logging
 If(!(Test-Path $logpath))
 {
  Write-Output "Log path not found, creating log file."
  New-Item $logpath -ItemType Directory
 }

 #Setup report directory
 If(!(Test-Path $reportpath))
 {
  Write-Output "Report path not found, creating folder."
  New-Item $Reportpath -ItemType Directory
 }

#Start Logging
Start-Transcript -Path $logfile

#Import the AzureAD Module
Import-Module AzureAD 
#Connect with Admin Creds, Accept DUO prompt.
Connect-AzureAD 
#Select Campus Production Tenant
Select-AzSubscription -Subscription c1835977-39e7-4415-a092-a77866f5afb8

#Define age of last activity
$age="365"

#Get All Stale Devices
$AllStaleDevices = Get-AzureADDevice -All:$true | Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}

#Count Number of Stale Devices
$AllStaleDevices | measure

#Create report and export results to spreadsheet
$AllStaleDevices | select-object -Property DisplayName, ObjectId, DeviceId, DeviceTrustType, ProfileType, ApproximateLastLogonTimestamp, AccountEnabled | export-csv $reportpath\StaleDeviceReport_$(get-date -f MM-dd-yyyy).csv


#Disable Stale Azure Devices
foreach ($device in $AllStaleDevices)
{
    Write-Host "Disabling:" $($device.DisplayName)
    Set-AzureADDevice -ObjectId $($device.ObjectId) -AccountEnabled:$false
    Write-Host ""
}  

#End Transcript
Stop-Transcript


#Region Delete From File

#Define Report File Path
#$Path = "C:\StaleDevices"
#$reportpath = "$Path\Reports"
$logfile = "$Path\Logs\Deleted-Devices-$(get-date -f yyyy-MM-dd-HH.mm).txt"

#Start Logging
Start-Transcript -Path $logfile


#Get Date from 30 Days Ago 
$30DaysAgo = (Get-Date).AddDays(-30)

#Format Date
$ReportAge = get-Date $30DaysAgo -f MM-dd-yyyy

#Output Report Path and Name
Write-Output "Stale Device Report" $ReportPath\StaleDeviceReport_$ReportAge.csv

#Get Report from 30 days ago
$Report = Get-ChildItem $ReportPath | Where-Object {$_.Name -like "StaleDeviceReport_$ReportAge.csv"}

#Import and Format CSV
$csv = Import-CSV $ReportPath\$Report | select -Property ObjectId

foreach ($obj in $csv)
{
    $Device = Get-AzureADDevice -ObjectId $obj.ObjectId

if ($device.AccountEnabled -match "false")
    {
        Write-output $Device.Displayname " is disabled"
        Write-output "Deleting Device Name: " $Device.DisplayName
        Write-Output "ObjectID: " $obj.ObjectId
        #Remove-AzureADDevice -ObjectId $($device.ObjectId)
        Write-Output ""
        Start-Sleep -Seconds 1
    } #End If

else 
    {
        Write-output $Device.Displayname " is not disabled"
        Write-output "Skipping this device"
        Write-output ""
    } #End Else


} #EndForEach


#EndRegion Delete From File

#Stop-Logs
Stop-Transcript

#Email Transcript
$EmailSubject = "AZ AD Stale Device Reports"
$EmailBody = "Azure AD Stale Device Reposts attached"
Send-MailMessage -from "AD_Team@gatech.edu" -to $EmailTo -subject $EmailSubject  -attachment $logpath -body $EmailBody -SmtpServer 'mxip1.gatech.edu'


#Cleanup Logs Older Than 90 Days
Get-ChildItem -path $Path -Recurse -Force | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-90)} | Remove-Item -Force




<#


Write-host "Warning! Do you want to disable stale Azure Active Directory Devices.  Continue?  (Y/N) (Default is No)" -ForegroundColor Yellow 
$Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
    { 
        Y {Write-host "Yes, Disabling all stale devices"; $PublishSettings=$true} 
        N {Write-Host "No, Cancel this immediately"; $PublishSettings=$false} 
        Default {Write-Host "Default, Canceling"; $PublishSettings=$false}
     }

######################################
#Disable Devices based on join type.#
######################################

############################
##Stale Azure AD Devices

$StaleAzureADDevices = Get-AzureADDevice -All:$true -Filter "DeviceTrustType eq 'AzureAD'" | Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
#Create report and export results to spreadsheet
$StaleAzureADDevices | Export-Csv $reportpath\Stale_Azure_AD_Devices_$(get-date -f MM-dd-yyyy).csv

#Disable Stale Azure AD Devices
foreach ($device in $StaleAzureADDevices)
{
    Write-Host "Disabling:" $($device.DisplayName)
    #Set-AzureADDevice -ObjectId $($device.ObjectId) -AccountEnabled:$false
}

###############################
##Stale Azure Registered Devices

$StaleAzRegisteredDevices = Get-AzureADDevice -All:$true -Filter "DeviceTrustType eq 'Workplace'" | Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
#Create report and export results to spreadsheet
$StaleAzRegisteredDevices | Export-Csv $reportpath\StaleAzure_Registered_Devices_$(get-date -f MM-dd-yyyy).csv

#Disable Stale Azure Registered Devices
foreach ($device in $StaleAzRegisteredDevices)
{
    Write-Host "Disabling:" $($device.DisplayName)
    #Set-AzureADDevice -ObjectId $($device.ObjectId) -AccountEnabled:$false
}

###################################
##Stale Azure Hybrid Joined Devices

$StaleHybridDevices = Get-AzureADDevice -All:$true -Filter "DeviceTrustType eq  'ServerAD'" | Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
#Create report and export results to spreadsheet
$StaleHybridDevices | Export-Csv $reportpath\Stale_Hybrid_Devices_$(get-date -f MM-dd-yyyy).csv

#Disable Stale Azure Hybrid Joined Devices
foreach ($device in $StaleHybridDevices)
{
    Write-Host "Disabling:" $($device.DisplayName)
    #Set-AzureADDevice -ObjectId $($device.ObjectId) -AccountEnabled:$false
}  


##################
##Delete Devices##
##################


#Report All Stale and Disabled Devices
$ASDD = Get-AzureADDevice -All:$true -Filter "AccountEnabled eq false" | Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
$ASDD | measure
$ASDD | select-object -Property DisplayName, ObjectId, DeviceId, DeviceTrustType, ProfileType, ApproximateLastLogonTimestamp, AccountEnabled | export-csv $reportpath\All_Disabled_Devices_Report_$(get-date -f MM-dd-yyyy).csv
foreach ($device in $ASDD)
{
  ##  Write-Host "Deleting: " $($device.DisplayName)
  ##  Remove-AzureADDevice -ObjectId $($device.ObjectId)
}

#Delete Disabled & Stale Azure AD Devices
$DAD = Get-AzureADDevice -All:$true -Filter "(AccountEnabled eq false) and (DeviceTrustType eq  'AzureAD')"| Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
$DAD | measure
$DAD| select-object -Property DisplayName, ObjectId, DeviceId, DeviceTrustType, ProfileType, ApproximateLastLogonTimestamp, AccountEnabled | export-csv $reportpath\Disabled_AzureAD_Device_Report_$(get-date -f MM-dd-yyyy).csv
foreach ($device in $DD)
{
 ##   Write-Host "Deleting: " $($device.DisplayName)
 ##   Remove-AzureADDevice -ObjectId $($device.ObjectId)
}

#Delete Disabled & Stale Azure Registered Devices
$DARD = Get-AzureADDevice -All:$true -Filter "(AccountEnabled eq false) and (DeviceTrustType eq  'Workplace')"| Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
$DARD | measure
$DARD | select-object -Property DisplayName, ObjectId, DeviceId, DeviceTrustType, ProfileType, ApproximateLastLogonTimestamp, AccountEnabled | export-csv $reportpath\Disabled_AzureRegistered_Device_Report_$(get-date -f MM-dd-yyyy).csv
foreach ($device in $DD)
{
 ##  Write-Host "Deleting: " $($device.DisplayName)
 ##  Remove-AzureADDevice -ObjectId $($device.ObjectId)
}

#Delete Disabled & Stale Azure Hybrid Joined Devices
$DHJD = Get-AzureADDevice -All:$true -Filter "(AccountEnabled eq false) and (DeviceTrustType eq  'ServerAD')"| Where {$_.ApproximateLastLogonTimeStamp -lt (Get-Date).AddDays(-$age)}
$DHJD | measure
$DHJD| select-object -Property DisplayName, ObjectId, DeviceId, DeviceTrustType, ProfileType, ApproximateLastLogonTimestamp, AccountEnabled | export-csv $reportpath\Disabled_HybridJoined_Device_Report_$(get-date -f MM-dd-yyyy).csv
foreach ($device in $DD)
{
 ##   Write-Host "Deleting: " $($device.DisplayName)
 ##   Remove-AzureADDevice -ObjectId $($device.ObjectId)
}

#>
