﻿#FindOrphanedGPOs.ps1
<#
This script will find and print all orphaned Group Policy Objects (GPOs).

Group Policy Objects (GPOs) are stored in two parts:

1) GPC (Group Policy Container). The GPC is where the GPO stores all the AD-related configuration under the
   CN=Policies,CN=System,DC=... container, which is replicated via AD replication.
2) GPT (Group Policy Templates). The GPT is where the GPO stores the actual settings located within SYSVOL
   area under the Policies folder, which is replicated by either File Replication Services (FRS) or
   Distributed File System (DFS).

This script will help find GPOs that are missing one of the parts, which therefore makes it an orphaned GPO.

A GPO typically becomes orphaned in one of two different ways:

1) If the GPO is deleted directly through Active Directory Users and Computers or ADSI edit.
2) If the GPO was deleted by someone that had permissions to do so in AD, but not in SYSVOL. In this case,
   the AD portion of the GPO would be deleted but the SYSVOL portion of the GPO would be left behind.

Although orphaned GPT folders do no harm they do take up disk space and should be removed as a cleanup task.

Lack of permissions to the corresponding objects in AD could cause a false positive. Therefore, verify GPT
folders are truly orphaned before moving or deleting them.

Original script written by Sean Metcalf
http://blogs.metcorpconsulting.com/tech/?p=1076

Release 1.1
Modified by Jeremy@jhouseconsulting.com 29th August 2012
Modified by Roger Higgins June 15 2016

#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter()]
    [string]
    $Path = "G:\Orphaned-GPOs\Backup-$(get-date -f yyyy-MM-dd)",

    [Parameter()]
    [string]
    $logpath = "G:\Orphaned-GPOs\Logs\Log-$(get-date -f yyyy-MM-dd-HH.mm).txt"
    )


#setup path
New-Item -Path $Path -ItemType Directory

#Setup logging
If(!(Test-Path $logpath))
{
    Write-Host -ForegroundColor DarkYellow "Log path not found, creating $logpath."
    Write-Host ""
    New-Item $logpath 
}

#Start Logging
Start-Transcript -Path $logpath

$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
# Get AD Domain Name
$DomainDNS = $Domain.Name
# Get AD Distinguished Name
$DomainDistinguishedName = $Domain.GetDirectoryEntry() | select -ExpandProperty DistinguishedName  

$GPOPoliciesDN = "CN=Policies,CN=System,$DomainDistinguishedName"
$GPOPoliciesSYSVOLUNC = "\\$DomainDNS\SYSVOL\$DomainDNS\Policies"

Write-Host -ForegroundColor Green "Finding all orphaned Group Policy Objects (GPOs)...`n"

Write-Host -ForegroundColor Green "Reading GPO information from Active Directory ($GPOPoliciesDN)..."
$GPOPoliciesADSI = [ADSI]"LDAP://$GPOPoliciesDN"
[array]$GPOPolicies = $GPOPoliciesADSI.psbase.children
ForEach ($GPO in $GPOPolicies) { [array]$DomainGPOList += $GPO.Name }
#$DomainGPOList = $DomainGPOList -replace("{","") ; $DomainGPOList = $DomainGPOList -replace("}","")
$DomainGPOList = $DomainGPOList | sort-object 
[int]$DomainGPOListCount = $DomainGPOList.Count
Write-Host -ForegroundColor Green "Discovered $DomainGPOListCount GPCs (Group Policy Containers) in Active Directory ($GPOPoliciesDN)`n"

Write-Host -ForegroundColor Green "Reading GPO information from SYSVOL ($GPOPoliciesSYSVOLUNC)..."
[array]$GPOPoliciesSYSVOL = Get-ChildItem $GPOPoliciesSYSVOLUNC
ForEach ($GPO in $GPOPoliciesSYSVOL) {If ($GPO.Name -ne "PolicyDefinitions") {[array]$SYSVOLGPOList += $GPO.Name }}
#$SYSVOLGPOList = $SYSVOLGPOList -replace("{","") ; $SYSVOLGPOList = $SYSVOLGPOList -replace("}","")
$SYSVOLGPOList = $SYSVOLGPOList | sort-object 
[int]$SYSVOLGPOListCount = $SYSVOLGPOList.Count
Write-Host -ForegroundColor Green "Discovered $SYSVOLGPOListCount GPTs (Group Policy Templates) in SYSVOL ($GPOPoliciesSYSVOLUNC)`n"

## COMPARE-OBJECT cmdlet note:
## The => sign indicates that the item in question was found in the property set of the second object but not found in the property set for the first object. 
## The <= sign indicates that the item in question was found in the property set of the first object but not found in the property set for the second object.

# Check for GPTs in SYSVOL that don't exist in AD
[array]$MissingADGPOs = Compare-Object $SYSVOLGPOList $DomainGPOList -passThru | Where-Object { $_.SideIndicator -eq '<=' }
[int]$MissingADGPOsCount = $MissingADGPOs.Count
$MissingADGPOsPCTofTotal = $MissingADGPOsCount / $DomainGPOListCount
$MissingADGPOsPCTofTotal = "{0:p2}" -f $MissingADGPOsPCTofTotal  
Write-Host -ForegroundColor Yellow "There are $MissingADGPOsCount GPTs in SYSVOL that don't exist in Active Directory ($MissingADGPOsPCTofTotal of the total)"
If ($MissingADGPOsCount -gt 0 ) {
  Write-Host "These are:"
  $MissingADGPOs
}
Write-Host "`n"

# Check for GPCs in AD that don't exist in SYSVOL
[array]$MissingSYSVOLGPOs = Compare-Object $DomainGPOList $SYSVOLGPOList -passThru | Where-Object { $_.SideIndicator -eq '<=' }
[int]$MissingSYSVOLGPOsCount = $MissingSYSVOLGPOs.Count
$MissingSYSVOLGPOsPCTofTotal = $MissingSYSVOLGPOsCount / $DomainGPOListCount
$MissingSYSVOLGPOsPCTofTotal = "{0:p2}" -f $MissingSYSVOLGPOsPCTofTotal  
Write-Host -ForegroundColor Yellow "There are $MissingSYSVOLGPOsCount GPCs in Active Directory that don't exist in SYSVOL ($MissingSYSVOLGPOsPCTofTotal of the total)"
If ($MissingSYSVOLGPOsCount -gt 0 ) {
  Write-Host "These are:"
  $MissingSYSVOLGPOs
}
Write-Host "`n"


#prompt user to continue
Write-Host -ForegroundColor DarkYellow "Number of GPOs in above report: "$MissingADGPOs.count
Write-Host ""
Write-Host -ForegroundColor DarkYellow "To Proceed enter y to delete all results"
$userInput = read-host “Press y to continue...”
If ($userInput -ne 'y') { write-output "exiting..."; exit 1 }


#Create Report and Delete
foreach ($gpt in $MissingADGPOs)     
{  
#Output all with GUID and TimeStamps to $path
Get-ChildItem -Path "\\ad.gatech.edu\SYSVOL\ad.gatech.edu\Policies"  | where name -Like $gpt  | select $gpt, CreationTime, LastWriteTime, LastAccessTime | out-file $path\OrphanedGPOs-Report$(get-date -f yyyy-MM-dd).txt -Append

#Backup directory about to be deleted.
Get-Item "D:\Windows\SYSVOL\domain\Policies\$gpt" | Copy-Item -Destination "G:\Orphaned-GPOs\Backup-$(get-date -f yyyy-MM-dd)"

#output item to delete
Write-Host -ForegroundColor DarkYellow "Deleting: $gpt "
Write-Host ""

Start-Sleep -Seconds 1

#delete item
Get-Item -Path "\\ad.gatech.edu\SYSVOL\ad.gatech.edu\Policies\$gpt" | Remove-Item -Recurse -Confirm:$false   


#$DeletGPO = Get-Item -Path "D:\Windows\SYSVOL\domain\Policies\$gpt"
#Copy-Item $DeletGPO -Destination $Path
#Get-Item $DeletGPO | select *
#$DeletGPO  | Remove-Item -Recurse -Confirm:$false    
#Remove-Item $DeletGPO  -Recurse -Confirm:$false 

}


#Stop Logging
Stop-Transcript


<#


$MissingADGPOs | out-file "G:\Orphaned-GPOs\MissingGPOs-$(get-date -f yyyy-MM-dd).txt"
$GUIDs = Get-Content "G:\Orphaned-GPOs\MissingGPOs-$(get-date -f yyyy-MM-dd).txt"
#Create Report and $
foreach ($gpt in $GUIDs)     
{  
Write-Host -ForegroundColor DarkYellow "Deleting: $gpt "
Get-Item -Path "D:\Windows\SYSVOL\domain\Policies\$gpt" | Remove-Item -Force -Recurse -Confirm:$false   

}

D:\Windows\SYSVOL\domain\Policies
%systemroot%\SYSVOL\Domain\Policies

D:\Windows\SYSVOL\sysvol\ad.gatech.edu\Policies
%systemroot%\SYSVOL\sysvol\DomainName.com\Policies

\\ad.gatech.edu\SYSVOL\ad.gatech.edu\Policies

#>


