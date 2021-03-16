# Get Out of Date VM Tools - Report - Update VMware Tools
# Test Usage - ".\update-tools.ps1 -vcenter "bcdc01m01vc01.ad.gatech.edu" -test".
# Example of updating a select folder - (Get-Datacenter 'DataCenterName' | Get-Folder "FolderName" | Get-VM)
# Created by - mfranklin7@gatech
######################################################


[CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(Mandatory=$false)]
        [String[]]$vcenter=@("europa.ad.gatech.edu","ganymede.ad.gatech.edu","coda01c01vc01.ad.gatech.edu"),
        [Parameter(Mandatory=$false)]
        [String[]]$EmailTo="oit-ai-vm@lists.gatech.edu",
        [Parameter(Mandatory=$false)]
        [String]$logpath = "C:\logs\Update-Tools\Update-Tools-$(get-date -f yyyy-MM-dd-HH.mm).txt",
        [Parameter(Mandatory=$False)]
        [Switch]$Test
    )

#Load all VMware Modules.
Get-Module -ListAvailable VM* | Import-Module

#Setup Credentials
$VcenterCredPath = "$env:UserProfile\vcenter-creds.xml"
If (!(Test-Path $VcenterCredPath)) {
 $VcenterCred = Get-Credential -Message "Please enter your credentials for Vcenter"
 $VcenterCred | Export-Clixml -Path $VcenterCredPath
} else {
 $VcenterCred = Import-Clixml -Path $VcenterCredPath
}
$username = $VcenterCred.UserName
$password = $VcenterCred.GetNetworkCredential().Password


#Verify the log directory exists
If(!(Test-Path $logpath)){
    Write-Output "Log path not found, creating folder."
    New-Item $logpath 
}


#Start Logging
Start-Transcript -Path $logpath


#Connect to vCenter Server(s)
foreach ($element in $vcenter) {
	Connect-VIServer -server $element -User $UserName -Password $Password | out-null
    If (!($?)) {
        Throw "Cannot Connect To VI Server"
        Stop-Transcript
        Exit
    }
    Write-Output "Connection to $element successful"
}


# Get All VMs that have Vmware TOols Status OutOfDate
$OutofDateVMs=Get-VM | % { get-view $_.id } |Where-Object {$_.Guest.ToolsVersionStatus -like "guestToolsNeedUpgrade"} | select name, @{Name=“ToolsVersion”; Expression={$_.config.tools.toolsversion}}, @{ Name=“ToolStatus”; Expression={$_.Guest.ToolsVersionStatus}}
Write-Output "VMs with out of date tools" 
Write-Output $OutofDateVMs 


# Update All VMs that have Vmware TOols Status OutOfDate - Do not reboot.
ForEach ($VM in $OutOfDateVMs){
Write-Output "Updating VM Tools"
Write-Output ($VM | select name, @{Name=“ToolsVersion”; Expression={$_.config.tools.toolsversion}})
Update-Tools -NoReboot -VM $VM.Name -Verbose

 If (!($Test)) {
                Update-Tools $VM -Confirm:$false
            } else {
                Write-Output "Whatif: Testing; does not update tools."
            }

			Write-Output "Tools have been updated. "
}


#Stop Logging
Stop-Transcript


#Logoff Vcenter.
foreach ($element in $vcenter) {
	Disconnect-VIServer -server $element -Confirm:$false
}

#Email Transcript
$EmailSubject = "VMware Tools Update Report"
$EmailBody = "Attached is the VMware Tools report."
Send-MailMessage -from "root@ts.gatech.edu" -to $EmailTo -subject $EmailSubject  -attachment $logpath -body $EmailBody -SmtpServer 'mxip1.gatech.edu'


#Cleanup Snapshot Logs Older Than 60 Days
gci -path $logpath -Recurse -Force | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-60)} | Remove-Item -Force

