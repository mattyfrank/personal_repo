# GTADComputerCleanup

## SYNOPSIS
This a script designed to assist in cleaning up computer accounts that are no longer in use within active directory.

## DESCRIPTION
Providing a SearchScope is mandatory and must be done using DistinguishedName convention. So a typical ad.gatech.edu/OIT/AI/Workstations OU would be the following:

``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu"
```

By default the script will export a list of the computer accounts that have not been logged into in the last year.  It will also export a list of ALL COMPUTER ACOCUNTS with thier Bitlcoker Recovery Keys that are stored in Active Directory. The command above does exactly this.

*IMPORTANT: No compuer accounts will be deleted unless -RemoveStaleObjects is set to $ture as below.  You will be prompted to confirm deletion as well.*

``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObjects $true
```
The script provides several key pieces of functionality listed below:

1. Identification and Export of computer accounts that may be stale.  Identification is keyed off of the "LastLogonDate" which has proven to be effective in identifying unused computer accounts regardless of operating system.

Export of computer accounts is done by default to a file "StaleComputerAccountList.csv" but can be turned on explicity and sent to another path as below.

```Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportCompuerAccountList $true -ComputerAccountListPath ".\MyComputerAccountList.csv"
```
2. Export to file of Bitlocker Keys of the computer accounts within scope. YOU MUST LAUNCH AS AN OUADMIN FOR THIS TO WORK!

Export of Bitlocker Keys is done by default to a file "ExportedBitlockerRecoveryKeys.csv" but can be turned on explicity and sent to another path as below.

``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportBitlockerKeys $true -KeyOutputPath ".\MyBitlockerRecoveryKeys.csv"
```

3. Removal of computer accounts over the default or given threshold.  The default threshold is 1 year.

``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObject $ture -CutoffDate "2016-01-01"
```

.EXAMPLE
Export List of Affected comptuers and backup Bitlocker Recovery Keys in the SearchBase.

``` Powershell
./GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu"
```
Explictly define export of computer acounts and custom path.
``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportCompuerAccountList $true -ComputerAccountListPath ".\MyComputerAccountList.csv"
```
Export Bitlocker Recover keys and explicitly define path.
``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -ExportBitlockerKeys $true -KeyOutputPath ".\MyBitlockerRecoveryKeys.csv"
```
Remove Computer Objects that have not been last logged in since 2016-01-01.
``` Powershell
GTADComputerAccountCleanup.ps1 -SearchBase "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" -RemoveStaleObject $ture -CutoffDate "2016-01-01"
```

## NOTES
Please email support@oit.gatech.edu and reference 'GTAD Computer Account Cleanup Script' for further assistance.
