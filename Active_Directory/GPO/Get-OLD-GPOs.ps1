$age =3092 #Days since Windows 2012 was released 8 years
$OldGPO = Get-GPO -all | where {$_.CreationTime -lt (Get-Date).AddDays(-$age)}
$OldGPO.count
$oldGPO | Export-Csv 'C:\Users\matthew\OneDrive - Georgia Institute of Technology\Desktop\OLD-GPO.csv'