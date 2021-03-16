

# office365 - getinfo.ps1
# Script to get user information, good for Office 365 
# Script can be run from powershell command line with the account to check as a parameter - ".\getinfo.ps1 GTaccount" 
# or just right click and "run with powershell" and it will prompt for the account you wish to check 
# Requires active directory module found on server or with RSAT

# Get userID to check #
param($samID)
if ($samID -eq $null) 
{
cls
$samid = read-host "Please enter the GT Account to check" 

}

# Add activedirectory module#
Import-Module activedirectory

# Get userID/Passwd to login with#

if($cred -eq $null){$cred = Get-Credential -Message "Office365 Search Login" -UserName $env:username"@gatech.edu"}


# Connect to Microsoft Online#
Import-Module MSOnline
Connect-MsolService -Credential $cred



#output data#
"GTAD Properties" |Out-Host
"----------------------------" |Out-Host
$user_adobject = get-aduser $samID -Properties *
$user_adobject | Select-Object DisplayName,GivenName,Surname, DistinguishedName, UserPrincipalName, Department, Enabled, extensionAttribute11,, extensionAttribute12,, extensionAttribute14,mail,proxyaddresses,targetaddress |Out-Host


"Office 365 Cloud Properties" |Out-Host
"----------------------------" |Out-Host
#check for deleted user status"
$deleted = Get-MsolUser -ReturnDeletedUsers -searchstring $samID | Select-Object UserPrincipalName
if ($deleted -ne $null) {$samID + " is in Deleted Users" |Out-Host}
ElseIf ($deleted -eq $null) 
{
 $o365_user = Get-MsolUser -UserPrincipalName $samID@gatech.edu | select-Object DisplayName, FirstName, LastName, UserPrincipalName, IsLicensed, Licenses,
LastDirSyncTime, BlockCredential, UsageLocation, ValidationStatus 
$o365_user|select-Object DisplayName, FirstName, LastName, UserPrincipalName, IsLicensed,LastDirSyncTime, BlockCredential, UsageLocation, ValidationStatus |Out-Host
$o365_userlicense = $o365_user.Licenses


"Office 365 licenses" |Out-Host
"----------------------------" |Out-Host


Foreach($lic in $o365_userlicense){
write-host $lic.AccountSkuId
$lic_ServiceStatus = $lic.ServiceStatus
 foreach($lic_option in $lic_ServiceStatus){
 $lic_option_formatted = "- " + $lic_option.ServicePlan.ServiceName.ToString() + " " + $lic_option.ProvisioningStatus
 Write-Host $lic_option_formatted
}

}

}
