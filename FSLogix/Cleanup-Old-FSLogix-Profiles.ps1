#CleanupFSLogix Profiles over 365 days. 

$path = "\\nas2-upm.matrix.gatech.edu\vlab_upm1\FslogixProfiles\RDSH"

#set profile age
$age = "365"

#Get Old Profiles, that have not been accessed within a year
Write-Host "Searching for profiles where LastWriteTime is older than:" (Get-Date).AddDays(-$age)
$oldprofiles = Get-ChildItem  -Filter *.vhdx -path $Path -Recurse -Force | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$age)} 

#Count Profiles
#typically 2 files per profile
Write-Host $oldprofiles.Count "Stale Profile/Office Containers Found."
Write-Host ""


#Remove Old Profiles
foreach ($profile in $oldprofiles)
{
    $directory = $profile.Directory
    
    Write-Host "Stale Profile:" $directory\$profile
    Write-Host $profile "Last-Write-Time:" $profile.LastWriteTime
    Write-Host ""
    
    Write-Host "Deleting:" $directory\$profile
    Remove-Item $directory\$profile
    Write-Host ""


    $files = get-childitem $directory

    if ($files.count -eq 0)
    {
        Write-Host "Empty Directory Found" $directory
        Write-Host $files.count "Child Items"
        Write-Host "Deleting Directory:" $directory
        Remove-Item $directory
        Write-Host ""
        Write-Host ""

     }

}
    

<#
#Delete Empty Folders. 
do {
  $dirs = Get-ChildItem $path -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | select -expandproperty FullName
  $dirs | Foreach-Object { Write-Host "Empty Dir:" $_ }
  $dirs | Foreach-Object { Remove-Item $_ }
} while ($dirs.count -gt 0)
#>