$IMG=Get-ADComputer -Filter "Name -like '*IMG*'" -SearchBase "OU=_XEN,DC=ad,DC=gatech,DC=edu" 
$Group="Golden-Images"

foreach ($obj in $IMG) {
Write-Output "Adding $($obj.SamAccountName) to $Group"
Add-ADGroupMember $Group -members $($obj.SamAccountName)
}