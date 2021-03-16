$DFSgroups = Get-ADGroup -Filter "name -like 'DFS-*'" | sort name

foreach ($adgroup in $DFSgroups) {
    $members = ($adgroup | get-adgroupmember -recursive).samaccountname
    foreach ($member in $members) {
        [PSCustomObject]@{
            Group   = $adgroup.name
            Members = $member
        }
    }
}



$groupObj = foreach ($adgroup in $DFSgroups) {
    $members = ($adgroup | get-adgroupmember -recursive).samaccountname
        [PSCustomObject]@{
            Group   = $adgroup.name
            Members = $members
        }
    } 


    