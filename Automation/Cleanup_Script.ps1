#Cleanup TEsting
connect-viserver callisto.ad.gatech.edu
Get-GPO -Name "Xen-FSLogix-OIT-Test1" | Remove-GPO -Confirm:$false
Get-ADComputer -Identity "OIT-Test1-IMG" | Remove-ADComputer -Confirm:$false
Get-ADOrganizationalUnit -Identity "OU=OIT-Test1,OU=OIT,OU=VDI,OU=Workstations,OU=_XEN,DC=ad,DC=gatech,DC=edu" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false
Get-Item -Path "\\nas2-upm.matrix.gatech.edu\vlab_upm1\OIT-Test1" | Remove-Item -Confirm:$false
Get-OSCustomizationSpec -Name "OIT-Test1-IMG" | Remove-OSCustomizationSpec -Confirm:$false
Get-VM -Name "OIT-Test1-IMG" | Shutdown-VMGuest | Remove-VM -Confirm:$false
Get-Folder -Name "OIT-Test1" | Remove-Folder -Confirm:$false
