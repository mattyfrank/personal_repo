 <# Remove all snapshots from vSphere older than X days
# Test Usage - ".\cleanup-snapshots.ps1 -vcenter "bcdc01m01vc01.ad.gatech.edu" -test".
# Created by - mfranklin7@gatech
# Credit to MTC@gatech for refactoring
######################################################>


[CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [Parameter(Mandatory=$false)]
        [String[]]$vcenter=@("europa.ad.gatech.edu","ganymede.ad.gatech.edu","coda01c01vc01.ad.gatech.edu","phobos.ad.gatech.edu","deimos.ad.gatech.edu"),
        [Parameter(Mandatory=$false)]
        [String[]]$EmailTo=("oit-ai-vm@lists.gatech.edu"),
        ##("matthew@gatech.edu","herbert.chang@oit.gatech.edu","fogburn3@gatech.edu","rick.florio@oit.gatech.edu","rick.brown@oit.gatech.edu"),##
        [Parameter(Mandatory=$false)]
        [Int]$Age="365",
        [Parameter(Mandatory=$false)]
        [String]$logpath = "C:\logs\Snapshots\snapclean-$(get-date -f yyyy-MM-dd-HH.mm).txt",
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
 

#Get all snapshots older than X, and delete them.
$snapshots = get-snapshot -vm * | Where-Object {$_.Created -lt (Get-Date).AddDays(-$age)} 
Write-Output "Snapshots existing before cleanup." 
	foreach ($x in $snapshots) {
            Write-Output "Removing snapshot... `n"
            Write-Output ($x | select VM,Name,SizeGB,Created)
            If (!($Test)) {
                #Remove-Snapshot -Snapshot $x -Confirm:$false
            } else {
                Write-Output "Whatif: Testing; does not remove snapshots."
            }
			Write-Output "Snapshot has been removed."
    } 


#LineBreak
Write-Output "`n" "`n" 

# List all remaining snapshots.
If((get-snapshot -vm *) -ne $null)
{
    $snapshotlist = get-snapshot -vm * | select VM, Name, SizeGB, @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}
    Write-Output "Current Snapshots in vSphere after cleanup."
    Write-Output $snapshotlist
    }
Else{
    Write-Output "No Snapshots to clean up."
}



#Stop Logging
Stop-Transcript


#Logoff Vcenter.
foreach ($element in $vcenter) {
	Disconnect-VIServer -server $element -Confirm:$false
}

#Email Transcript
$EmailSubject = "Snapshot Report - Snapshots over 365 Days"
$EmailBody = "Attached is a  snapshop report of snapshots over 365 days old."
#$EmailSubject = "Snapshot Cleanup Report"
#$EmailBody = "Attached is a vcenter snapshot cleanup report."
Send-MailMessage -from "root@ts.gatech.edu" -to $EmailTo -subject $EmailSubject  -attachment $logpath -body $EmailBody -SmtpServer 'mxip1.gatech.edu'


#Cleanup Snapshot Logs Older Than 60 Days
gci -path $logpath -Recurse -Force | Where-Object {!$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-60)} | Remove-Item -Force

 
