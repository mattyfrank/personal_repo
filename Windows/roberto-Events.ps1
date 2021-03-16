$hostname = hostname
$desktop = $env:USERPROFILE + '\desktop'
Set-Location $desktop
md $hostname
Set-Location $hostname
Get-EventLog -LogName security |Where-Object {$_.message -like "*roberto*" -or $_.message -like "*130.207.241.97*"-or $_.message -like "*130.207.241.96*" -or $_.message -like "*oit-sla-osp*" -or $_.message -like "*130.207.241.88*" -or $_.message -like "*added to a security-enabled local group.*"} |Format-Table -Wrap > "$hostname - events.txt"
get-eventlog -logname "security" -message "*failed*" -Newest 30 |Format-Table -Wrap > "$hostname - failed events.txt"