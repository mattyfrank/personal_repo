#This will allow you to translate Machine SID to Domain Computer Object
Get-ADComputer -Filter {SID -eq 'S-1-5-21-'}

