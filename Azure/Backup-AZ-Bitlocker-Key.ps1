$exportFile = "C:\TEMP\BitLockerReport.html"

#Install-Module -Name AzureRM -AllowClobber
Import-Module AzureRM
Login-AzureRmAccount
#Connect-AzureRmAccount

Import-Module AzureAD
Connect-AzureAD


#Prepare Context - REQUIRES TENANT ADMIN
$context = Get-AzureRmContext
    $tenantId = $context.Tenant.Id
    $refreshToken = @($context.TokenCache.ReadItems() | Where-Object {$_.tenantId -eq $tenantId -and $_.ExpiresOn -gt (Get-Date)})[0].RefreshToken
    $body = "grant_type=refresh_token&refresh_token=$($refreshToken)&resource=74658136-14ec-4630-ad9b-26e160ff0fc6"
    $apiToken = Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'
    $header = @{
        'Authorization'          = 'Bearer ' + $apiToken.access_token
        'X-Requested-With'       = 'XMLHttpRequest'
        'x-ms-client-request-id' = [guid]::NewGuid()
        'x-ms-correlation-id'    = [guid]::NewGuid()
    }

$AzureADDevices = Get-AzureADDevice -All:$true -Filter "AccountEnabled eq false" | ? {$_.deviceostype -eq "Windows"}

#Retrieve BitLocker keys
$deviceRecords = @()

$deviceRecords = foreach ($device in $AzureADDevices) {
        $url = "https://main.iam.ad.ext.azure.com/api/Device/$($device.objectId)"
        $deviceRecord = Invoke-RestMethod -Uri $url -Headers $header -Method Get
        $deviceRecord
    }

$Devices_BitlockerKey = $deviceRecords.Where({$_.BitlockerKey.count -ge 1})

$obj_report_Bitlocker = foreach ($device in $Devices_BitlockerKey){
    foreach ($BLKey in $device.BitlockerKey){
        [pscustomobject]@{
            DisplayName = $device.DisplayName
            driveType = $BLKey.drivetype
            keyID = $BLKey.keyIdentifier
            recoveryKey = $BLKey.recoveryKey
            }
    }
}
#HTML report

<#-- Create HTML report --#>
$body = $null

$body += "<p><b>AzureAD Bitlocker key report</b></p>"
$body += @"
<table style=width:100% border="1">
  <tr>
    <th>Device</th>
    <th>DriveType</th>
    <th>KeyID</th>
    <th>RecoveryKey</th>
  </tr>
"@

$body +=  foreach ($obj in $obj_report_Bitlocker){
"<tr><td>" + $obj.DisplayName + " </td>"
    "<td>" + $obj.DriveType + " </td>"
    "<td>" + $obj.KeyID + " </td>"
"<td>" + $obj.RecoveryKey + "</td></tr>"
}
  
$body += "</table>"

$body > $exportFile