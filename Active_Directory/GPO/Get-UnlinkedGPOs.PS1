# Script lists GPOs that not linked
#This script is intended to be used by CSR to delete their Unit's Unlinked GPOs. Use with Cauction!
#Created by Mfranklin.
#Shoutout to Powershell.
#GT admins in the house

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter()]
    [string]
    $Path = "Z:\Unlinked-GPO-Backups\Backup-$(get-date -f yyyy-MM-dd)",

    [Parameter()]
    [string]
    $logpath = "Z:\Unlinked-GPO-Backups\Logs\Log-$(get-date -f yyyy-MM-dd-HH.mm).txt",

    [Parameter()]
    [string]
    $Domain = "ad.gatech.edu",

    [Parameter()]
    [string]
    $Server = "gtad01.AD.GATECH.EDU"
    )



 #Setup logging
 If(!(Test-Path $logpath))
 {
    Write-host -ForegroundColor DarkYellow "Log path not found, creating $logpath."
    New-Item $logpath 
 }


#Start Logging
Start-Transcript -Path $logpath


#Create Backup Directories
If(!(Test-Path $path))
 {
    Write-host -ForegroundColor DarkYellow "Backup Directory not found, creating $path."
    New-Item -Path $Path -ItemType Directory
    New-Item -Path $Path\Reports -ItemType Directory
}

# import Activedirectory module
#Import-Module ActiveDirectory         
# import GroupPolicy module 
#Import-Module GroupPolicy         


#Setup Powershell
If (!(Get-module grouppolicy)) 
    {
        Write-host -ForegroundColor DarkYellow "Importing GPO Module."
        Import-Module grouppolicy
    } 
   
   
#Inform CSR the functionality of this script and confirm deletion.
Write-host -ForegroundColor DarkYellow  "Warning! This Script will DELETE all Unlinked GPOs! Do you want to Continue (Y/N)? (Default is No)" 
$Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
    { 
        Y {Write-host "Yes, searching for Unlinked GPOs"; $PublishSettings=$true} 
        N {Write-Host "No, Cancel this immediately"; $PublishSettings=$false} 
        Default {Write-Host "Default, Canceling"; $PublishSettings=$false}
    }
   
#######################################
#Region GTAD Admin GPO Cleanup

#Delete ALL GPOS that are unlinked

#Get ALL GPOs that are Unlinked 
#$UNLINKED = Get-GPO -All | Sort-Object displayname | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {$_.DisplayName } }
$UNLINKED = Get-GPO -All |Where-Object { $_ | Get-GPOReport -ReportType XML| Select-String -NotMatch "<LinksTo>" } 
$UNLINKED | Export-Csv "$path\All-UnLinkedGPOs_$(get-date -f yyyy-MM-dd).csv"

Write-Host ""
Write-Host -ForegroundColor DarkYellow "Unlinked GPOs to Delete: " $UNLINKED.count
Write-Host ""

    ForEach ($GPO in $UNLINKED) 
    {
        #Backup each GPO
        Write-Host -ForegroundColor DarkYellow  "Backing up GPO named:" $GPO.DisplayName
        Backup-GPO -Guid $GPO.ID -Domain $Domain -path $Path
        Write-Host ""
      
        #Create Report for each GPO
        Write-Host -ForegroundColor DarkYellow  "Generate GPO Report for:" $GPO.DisplayName
        Get-GPOReport -GUID $GPO.id -ReportType Html -Path "$Path\Reports\$($GPO.DisplayName).html"
        Write-Host ""
        
        #Add GPO to Log
        # $GPO | Out-File "$path\All-UnLinkedGPOs_$(get-date -f yyyy-MM-dd).txt" -Append
        #"{0}_{1}" -f $GPO.DisplayName, $GPO.id | out-file "$path\All-UnLinkedGPOs_$(get-date -f yyyy-MM-dd).txt" -Append
        #$GPO.DisplayName + '_' + $GPO.id -join ''| out-file "$path\All-UnLinkedGPOs_$(get-date -f yyyy-MM-dd).txt" -Append

        Start-Sleep -Seconds 3

        #Delete the GPO
        Remove-GPO $GPO -Confirm:$false
    }

$UNLINKED = Get-GPO -All |Where-Object { $_ | Get-GPOReport -ReportType XML| Select-String -NotMatch "<LinksTo>" } 
Write-Host -ForegroundColor DarkYellow "Unlinked GPOs to Delete: " $UNLINKED.count

#Output Completed
if ($UNLINKED.count -le "1")
{
    Write-Host ""
    Write-Host -ForegroundColor DarkYellow  "Finished running the script, all unlinked GPOs have now been removed."
    Write-Host ""
}
Else 
{
Write-Host ""
Write-Host -ForegroundColor DarkYellow "Unlinked GPOs detected, run script again"
}     

#Stop logging
Stop-Transcript


#EndRegion GTAD Admin GPO Cleanup


   


<#
########################################
#Region Self-Service GPO Cleanup for CSRs

   #Prompt admin for Unit Name/GPO Prefix.
   $UnitName = @()
   $input = (Read-Host "Please enter the GPO Prefix Naming scheme. Example 'OIT-'")
   if ($input -ne '') {$UnitName += $input}
   
   # Get GPOs that match the input provided by the user
   $UnitGPOs = Get-GPO -All | Sort-Object displayname | Where-Object {($_.displayname -like "$UnitName*")}
   
   # Get GPOs from the previous array that are unlinked.
   $UnlinkedUnitGPOs = $UnitGPOs | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {$_.DisplayName } }
   
   #Output Unlinked GPOs
   Write-Output $UnlinkedUnitGPOs.DisplayName
   
   #Delete the Unlinked GPOs that start with the Prefix the CSR entered.
      ForEach ($GPO in $UnlinkedUnitGPOs.DisplayName) {
      Backup-GPO -Name $GPO -Path $BackupPath
      Get-GPOReport -Name $GPO -ReportType Html -Path "c:\GPObackups\$Date\$GPO).html"
      $Gpo | Out-File "c:\GPObackups\$Date\UnLinkedGPOs$Date.txt" -Append
      Remove-GPO $GPO -Confirm:$false
      }

   #Output Completed
   Write-Host "Finished running the script, all unlinked GPOs have now been removed." 
   
   #EndRegion

   #>
   

   <#
   #Email Transcript
   $EmailSubject = "Report: Unlinked Group Policy Objects That Were Deleted."
   $EmailBody = "Attached is an output of all Unlinked GPOs that were deleted."
   $EmailAttachment= "$BackupPath\UnLinkedGPOs$Date.txt"
   $EmailFrom = "GTAD@oit.gatech.edu"
   $EmailTo = "matthew@gatech.edu"
   $SMTPServer = 'mxip1.gatech.edu'
   Send-MailMessage -from $EmailFrom -to $EmailTo -subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer -attachment $EmailAttachment
   #>
   
   
   #################
   #EXAMPLES-
   #This Command Will Return All Unlinked Policies
   #$UnLinkedGPOs = Get-GPO -All | Sort-Object displayname | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {$_.DisplayName } }
   ################
   #This Command Will Return Unlinked Policies that Match the UnitName
   #$GPOs=Get-GPO -All | Sort-Object displayname | Where-Object {($_.displayname -like "$UnitName*") -and ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" )} | Select DisplayName
   ################ 
   
   
   
   
   