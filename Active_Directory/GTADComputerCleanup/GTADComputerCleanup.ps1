########################################################
#
# GTADComputerCleanup.ps1
#
# This a script designed to assist in cleaning up computer accounts that are
# no longer in use within active directory.  See Usage below and please use
# with the appropriate level of caution.
#
# Version 1.0 - Initial release


<#

.SYNOPSIS
This a script designed to assist in cleaning up computer accounts that are no longer in use within active directory.

.DESCRIPTION
Providing a SearchScope is mandatory and must be done using DistinguishedName convention. So a typical ad.gatech.edu/OIT/AI/Workstations OU would be the following:

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu"

By default the script will export a list of the computer accounts that have not been logged into in the last year.  It will also export a list of ALL COMPUTER ACOCUNTS with thier Bitlcoker Recovery Keys that are stored in Active Directory. The command above does exactly this.

IMPORTANT: No compuer accounts will be deleted unless -RemoveStaleObjects is set to $true as below.  You will be prompted to confirm deletion as well.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObjects $true

The script provides several key pieces of functionality listed below:

1. Identification and Export of computer accounts that may be stale.  Identification is keyed off of the "LastLogonDate" which has proven to be effective in identifying unused computer accounts regardless of operating system.

Export of computer accounts is done by default to a file "StaleComputerAccountList.csv" but can be turned on explicity and sent to another path as below.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportCompuerAccountList $true -ComputerAccountListPath ".\MyComputerAccountList.csv"

2. Export to file of Bitlocker Keys of the computer accounts within scope. YOU MUST LAUNCH AS AN OUADMIN FOR THIS TO WORK!

Export of Bitlocker Keys is done by default to a file "ExportedBitlockerRecoveryKeys.csv" but can be turned on explicity and sent to another path as below.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportBitlockerKeys $true -KeyOutputPath ".\MyBitlockerRecoveryKeys.csv"

3. Removal of computer accounts over the default or given threshold.  The default threshold is 1 year.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObject $true -CutoffDate "2016-01-01"

.EXAMPLE
Export List of Affected comptuers and backup Bitlocker Recovery Keys in the SearchBase.

./GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu"

Explictly define export of computer acounts and custom path.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportCompuerAccountList $true -ComputerAccountListPath ".\MyComputerAccountList.csv"

Export Bitlocker Recover keys and explicitly define path.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportBitlockerKeys $true -KeyOutputPath ".\MyBitlockerRecoveryKeys.csv"

Remove Computer Objects that have not been last logged in since 2016-01-01.

GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObject $true -CutoffDate "2016-01-01"


.NOTES
Please email support@oit.gatech.edu and reference 'GTAD Computer Account Cleanup Script' for further assistance.

.LINK
http://www.oit.gatech.edu/

#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$SearchBase,
    [DateTime]$CutoffDate=[DateTime]::Today.AddDays(-365),
    [bool]$RemoveStaleObjects=$false,
    [bool]$ExportComputerAccountList=$true,
    [string]$ComputerAccountListPath=".\StaleComputerAccountList.csv",
    [bool]$ExportBitLockerKeys=$true,
    [string]$KeyOutputPath=".\ExportedBitlockerRecoveryKeys.csv"
)

Write-Output "Welcome to the Georgia Tech Active Directory Comptuer Object Cleanup Tool!"
 
$ComputerAccountList = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties LastLogonDate, Created, CanonicalName, OperatingSystem, OperatingSystemVersion, PasswordLastSet | ? {$_.LastLogonDate -lt $CutoffDate}


##### Identification of computer accounts to be removed

if ($ExportComputerAccountList -eq $true) {
    try {
        $ComputerAccountList | Export-Csv -Path $ComputerAccountListPath -NoTypeInformation
        Write-Output "Successfully Exported List of Computers that have not been authenticated in Active Directory since $CutoffDate to $ComputerAccountListPath."
    } catch {
        Write-Error "Failed to Export Computer Account List.  Please check file permissions for $ComputerAccountListPath."
    }
    

}


##### Bitlocker Key Export Process

if ($ExportBitLockerKeys -eq $true) {
    $computers = Get-ADComputer -Filter * -SearchBase $SearchBase

    $BitlockerKeys = @()

    foreach ($computer in $computers) {
          $dn = $computer.DistinguishedName
          $KeyADObjects = Get-ADObject -Filter * -SearchBase $dn -Properties * | Where-Object {$_.ObjectClass -eq "msFVE-RecoveryInformation"}

          foreach ($key in $KeyADObjects) {
              $keyExport = [PSCustomObject]@{
                  ComputerName = $computer.Name;
                  DNSName = $computer.DNSHostName;
                  ComputerDN = $computer.DistinguishedName;
                  KeyName = $key.Name;
                  KeyDN = $Key.DistinguishedName;
                  KeyGuid = $Key.ObjectGuid;
                  KeyPassword = $key.'msFVE-RecoveryPassword'
              }
              $BitlockerKeys += $keyExport
          }

    }

    # Error protection in case user ran as a non-admin

    if ($BitlockerKeys.Count -eq 0) {
        Write-Output "No AD Key objects found.  Are you logged in as an OU Admin?"
    } else  {
        try {
            $BitlockerKeys | Export-Csv -Path $KeyOutputPath -NoTypeInformation
            Write-Output "Successfully exported Bitlocker Keys to  $KeyOutputPath"
        }
        catch {
            Write-Error "Failed to export BitlockerKeys.  Check File Permissions."
        }
        
    }
    
}

if ($RemoveStaleObjects -eq $true) {

    if ($ComputerAccountList.Length -gt 0) {

        Write-Output "WARNING: The following computer accounts will be deleted.  Please take note and ensure that these are no longer in use."
        $ComputerAccountList | ft Name, LastLogonDate

        $ComputerAccountCount = $ComputerAccountList.Length

        $confirm = Read-Host "All of the $ComputerAccountCount computer accounts listed above will be REMOVED!  Are you sure you want to proceed? (Y/N)"

        if ($confirm -like "y") {

            try {
                $ComputerAccountList | Remove-ADObject -Recursive -Confirm:$false
            } catch {
                Write-Error "Computer Accounts could not be deleted.  Did you run PowerShell with the right permissions?"
            }

            
            
        } else {
            Write-Host "Operation Canceled.  None fo the Computer Objects have been removed."
        }

    } else {
        Write-Output "No computer accounts were found that would require cleanup. Exiting."
        Exit
    }
    
}  
