Get-ADComputer -Filter * -Properties LastLogonDate, Created | Export-CSV .\desktop\adcomputer-quick.csv -NoTypeInformation -Force