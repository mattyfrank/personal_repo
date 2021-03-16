#requires -runasadministrator 

#RunOnce Syntax-
#cmd.exe /C Powershell.exe –ExecutionPolicy Bypass -file C:\scripts\Powershell-Setup-MasterImage.ps1


#Get Volume C size and then resize the volume
$drive_letter = "C"
$size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax


#Create Local Admin - Set Password to Never Expire. 
$Username = "dilbert"
$Password = "password"
$group = "Administrators"
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never
    
    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE



#Create Local Directory, and Copy Install Files
md "C:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\Citrix\Public\VDA\1912" "c:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\Citrix\Public\Support Tools\CitrixOptimizer - v2.6.0.118.zip" "C:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\Nvidia\4.10\370.41_grid_win10_server2016_64bit_international" "C:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\VMWare\Vmware Tools\VMware-Tools-windows-11.0.5-15389592" "C:Installs"
