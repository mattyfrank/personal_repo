# make_new_computer_fromlist.ps1
# Script to create a new computer object in AD from a text file
# The txt file has to contain the host name and location (in X.500/ldap format) delimited by ":"
# The txt file can have an optional description as the third column.
# The txt file uses a ":" as delimiter since the default "," is used in the path
# Usage:  .\make_new_computer_fromlist.ps1
#         

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

# Change name/location of file to your environment
$File = "C:\temp\computer_list.txt"
$Content = Import-CSV $File -Delimiter : -Header Name,Path,Desc
ForEach ($co in $Content) {
  $CoName =$co.Name
  $CoPath =$co.Path
  $CoDesc =$co.Desc
  new-ADcomputer –name $CoName –SamAccountName $CoName -Path $CoPath -Description  $CoDesc 
}