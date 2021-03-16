#This will allow you to translate SID to Domain User Account
$objSID = New-Object System.Security.Principal.SecurityIdentifier `
    ("S-1-5-21-")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value
