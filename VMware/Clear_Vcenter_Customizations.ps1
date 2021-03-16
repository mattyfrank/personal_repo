#Clear VM Customizations
#mfranklin 01-2021

#Load all VMware Modules.
Get-Module -ListAvailable VM* | Import-Module

#Setup credentials
$VcenterCredPath = "$env:UserProfile\vcenter-creds.xml"
If (!(Test-Path $VcenterCredPath)) {
 $VcenterCred = Get-Credential -Message "Please enter your credentials for Vcenter"
 $VcenterCred | Export-Clixml -Path $VcenterCredPath
} else {
 $VcenterCred = Import-Clixml -Path $VcenterCredPath
}
$username = $VcenterCred.UserName
$password = $VcenterCred.GetNetworkCredential().Password

#connect to vcenter servers
$vcenter=@("bcdc01m01vc02.ad.gatech.edu","callisto.ad.gatech.edu","coda01c01vc01.ad.gatech.edu","coda01c03vc01.ad.gatech.edu","coda01m01vc01.ad.gatech.edu","europa.ad.gatech.edu","ganymede.ad.gatech.edu")
foreach ($server in $vcenter) {
	Connect-VIServer -server $server -User $UserName -Password $Password | out-null
    If (!($?)) {
        Throw "Cannot Connect To VI Server"
        Stop-Transcript
        Exit
    }
    Write-Output "Connection to $server successful"
}


#set age
$age="300"
#get old custom spec
$OldCustSpec = Get-OSCustomizationSpec * | Where-Object {$_.LastUpdate -lt (Get-Date).AddDays(-$age)} 
#list custom specs to be deleted
$OldCustSpec
#Delete old custom spec
$OldCustSpec |  Remove-OSCustomizationSpec -Confirm:$true



#NOTES


#confirmation notice
#$UserInput = Read-Host "Enter Y to continue..."
#if ($UserInput -eq 'Y') {​​​​ continue }​​​​ 
#else {​​​​ write-output 'input not understood or exiting' }​​​​

#Delete ALL custom spec
#Remove-OSCustomizationSpec "*"

#Example of prperties of custom spec
#Get-OSCustomizationSpec -Name "EXAMPLE" | select *

#Example of LastUpdate Field
#LastUpdat: 9/25/2020 10:33:42 AM
