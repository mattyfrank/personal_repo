
# Script lists GPOs that not linked anywhere

# imports Activedirectory module if it not already loaded
# ----------------------------------------------
if (-not (Get-Module ActiveDirectory)){            
    Import-Module ActiveDirectory         
  }
  
  # imports GroupPolicy module if it not already loaded
  # ----------------------------------------------
  if (-not (Get-Module GroupPolicy)){            
    Import-Module GroupPolicy         
  }
  
  
  Get-GPO -All | where{$_.DisplayName -like '*'} | 
      %{ 
         If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" )
          {
          Write-Host $_.DisplayName,";", $_.owner,";", $_.id
          }
      }
  