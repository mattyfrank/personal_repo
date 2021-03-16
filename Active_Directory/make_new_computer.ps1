# make_new_computer.ps1
# Script to create a new computer object in AD
# Usage:  .\make_new_ computer.ps1 <computer name -required> <OU to create object in -required> <optional description>
#         .\make_new_computer.ps1 "newpc" "OU=laptops,DC=gatech,DC=edu" 
#         .\make_new_computer.ps1 "newtestpc" "OU=laptops,DC=gatech,DC=edu" "loaner PC" 

Param(
  [Parameter (mandatory=$true)]
  [String] $CoName,

  [Parameter (mandatory=$true)]
  [string] $CoPath,

  [string] $CoDesc
)

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory         
}

new-ADcomputer –name $CoName –SamAccountName $CoName -Path $CoPath -Description $CoDesc -Enabled $true 