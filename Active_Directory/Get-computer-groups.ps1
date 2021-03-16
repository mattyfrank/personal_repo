$searcher = [adsisearcher]"(&(objectCategory=computer)(cn=$env:COMPUTERNAME))"
$searcher.FindOne().Properties.memberof -replace '^CN=([^,]+).+$','$1'
