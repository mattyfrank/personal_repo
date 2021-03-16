Get-ADComputer –filter * -Properties ‘OperatingSystem -eq "Windows Server 2008 R2 Enterprise"’ | Format-Table DistinguishedName,OperatingSystem –AutoSize | Sort-object OperatingSystem


Get-ADComputer –filter * -Properties * | Format-Table DistinguishedName,OperatingSystem –AutoSize | Out-GridView


Get-ADComputer -filter ‘OperatingSystem -eq "Windows Server 2008 R2 Enterprise"’ | Export-Csv -Path C:\2008Servers.csv