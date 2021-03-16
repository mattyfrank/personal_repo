Connect-AzureAD

##Get ActiveDir ComputerObject's userCertificate; Clear AD Computer Certificate
Get-ADComputer coe-F2020-IMG | select userCertificate
$ComputerObj = Get-ADComputer ECE-2020-IMG -Properties *
$ComputerObj.userCertificate
Set-ADComputer $ComputerObj -Certificates $Null


##Get-AzureHybrid Devices where name is like *-IMG; Remove AAD Decive; Clear Certificate on ActiveDir ComputerObject. 
$Devices =Get-AzureADDevice -All $true -Filter "DeviceTrustType eq 'ServerAD'" | where displayname -like "*img"
foreach ($obj in $Devices) {
Write-Host Removing $obj.DisplayName from AAD
Remove-AzureADDevice -ObjectID $obj.ObjectId
Write-Host Removing $obj.DisplayName userCertificate
Set-ADComputer $obj.DisplayName -Certificates $Null
}


##Add AD ComputerObject to SecurityGroup
##ComputerObjects where Name is like *-IMG and AD Security Group 'Golden-Images'
$IMG=Get-ADComputer -Filter "Name -like '*IMG*'" -SearchBase "OU=_XEN,DC=ad,DC=gatech,DC=edu"
$Group="Golden-Images"
foreach ($obj in $IMG) {
Write-Output "Adding $($obj.SamAccountName) to $Group"
Add-ADGroupMember $Group -members $($obj.SamAccountName)
}



#Get AAD Registered Devices.
Get-AzureADDevice -All $true -Filter "DeviceTrustType eq 'ServerAD' and ProfileType eq 'RegisteredDevice'" | where displayname -like "*-img" 


#Get Azure AD Device by DeviceID
Get-AzureADDevice -All $true | Where DeviceId -eq "670923dc-e529-4dfe-9d0e-d78be904626c"

#Search AzureADdevices by DeviceID.
$Devices =Get-AzureADDevice -All $true -Filter "DeviceTrustType eq 'ServerAD'" | where displayname -like "*img"
foreach ($obj in $Devices) {
Write-Host Searching for Duplicate DeviceID $obj.DeviceId
Get-AzureADDevice -All $true | Where DeviceId -eq "$obj.DeviceId"
}


#Get Azure AD Device by Object ID
Get-AzureADDevice -ObjectId '25e418a8-6843-4e32-8020-b6f0ca3d9dea'



#Get Azure AD Device Properties
Get-AzureADDevice -ObjectId '25e418a8-6843-4e32-8020-b6f0ca3d9dea' | Select *
