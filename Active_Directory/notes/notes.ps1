Get-ADUser -Filter {(Enabled -eq $false)} -SearchBase "OU=Other,OU=GT_ADM,DC=ad,DC=gatech,DC=edu" | FT Name, Enabled -Autosize

Get-ADUser -Filter * -Property Enabled | Where-Object {$_.Enabled -like “false”} | FT Name, Enabled -Autosize


Get-ADUser -Filter {(Enabled -eq $false)} -SearchBase "OU=Other,OU=GT_ADM,DC=ad,DC=gatech,DC=edu" | Export-Csv Disabled-GT-Other.csv


Get-ADUser -Filter * -SearchBase "OU=Other,OU=GT_ADM,DC=ad,DC=gatech,DC=edu" | select Name, Enabled | Export-Csv All-GTOther.csv


https://activedirectorypro.com/how-to-get-ad-users-password-expiration-date/


Copy-GPO -SourceName "TestGpo1" -TargetName "TestGpo2"

Set-GPLink -Name TestGPO -Target "ou=MyOU,dc=contoso,dc=com" -LinkEnabled Yes