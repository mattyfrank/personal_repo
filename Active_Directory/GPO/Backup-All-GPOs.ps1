#Backups all GPOs
#Output is folder named with GUID
#Backup-GPO -All -Path "G:\GPO_Backup\test1" -Comment "Backup All GPOs $(get-date)"


#Region setup

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter()]
    [string]
    $Path = "G:\GPO-Backups\",

    [Parameter()]
    [string]
    $logpath = "G:\GPO-Backups\Logs\GPO-Backup-$(get-date -f yyyy-MM-dd-HH.mm).txt",

    [Parameter()]
    [string]
    $Domain = "ad.gatech.edu",

    [Parameter()]
    [string]
    $Server = "gtad01.AD.GATECH.EDU"
    )



  #Setup logging
  If(!(Test-Path $logpath))
  {
    Write-Output "Log path not found, creating folder."
    New-Item $logpath 
  }


#Start Logging
Start-Transcript -Path $logpath

#EndRegion setup

#Region Get-GPO    

#Get-All GPOs and Backup GPOs
$GPOs = Get-GPO -All -Domain $domain -Server $Server

#create backup folder named by date
$date = Get-Date -F "yyyy-MM-dd-HH"
$NewFolder = "$path\$date"

New-item $NewFolder -ItemType Directory
Write-Host "GPO's will be backed up to $NewFolder"

#EndRegion Get-GPOs

#Region Backup-GPO  
ForEach ($GPO in $GPOs) 
{
  #Output each GPO being backed up
  Write-Host "Backing up GPO named: $($GPO.Displayname)"
 
  $BackupInfo = Backup-GPO -Guid $GPO.ID -Domain $Domain -path $NewFolder -Server $Server
  #$BackupInfo = Backup-GPO -Name $GPO.DisplayName -Domain $Domain -path $NewFolder -Server $Server
  $GpoBackupID = $BackupInfo.ID.Guid
  $GpoGuid = $BackupInfo.GPOID.Guid
  $GpoName = $BackupInfo.DisplayName
  $CurrentFolderName = $NewFolder + "\" + "{"+ $GpoBackupID + "}"
  $NewFolderName = $NewFolder + "\" + $GPOName + "___" + "{"+ $GpoBackupID + "}"
  $ConsoleOutput = $GPOName + "___" + "{"+ $GpoBackupID + "}"

  #Rename the individual GPO folders from GPO GUID to the GPO Displayname + GUID
  Rename-Item $CurrentFolderName -NewName $NewFolderName
}
#EndRegion Backup GPOs

#Cleanup Backups Older Than 60 Days
#Get-ChildItem -path $Path| Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | Remove-Item -Force
