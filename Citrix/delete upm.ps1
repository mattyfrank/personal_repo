#Map Network Drive
net use Z: \\nas2-upm.matrix.gatech.edu\vlab_upm1

#Reset ACLs
takeown /F Z:\DeleteMe\FslogixProfiles-BAD\*.* /R /A 
icacls Z:\DeleteMe\FslogixProfiles-BAD\*.* /T /grant administrators:F
CD Z:\DeleteMe\FslogixProfiles-BAD\*.* icacls * /T /Q /C /RESET

#disconnect open files
$computerName = 'nas2-upm.matrix.gatech.edu'
$folder = "C:\vol\vlab_upm1\DeleteMe\FslogixProfiles-BAD"
$UNC = '\\nas2-upm.matrix.gatech.edu\vlab_upm1\DeleteMe\FslogixProfiles-BAD'

$pattern = '^.+ (?<FileId>\d+) (?<User>[^ ]+).+ (?<OpenFile>C:.+\\SpecificFolder\\.*)$'
$openfiles = openfiles /query /s $computerName /v | Select-String -Pattern $pattern | ForEach-Object {[void]($_.Line -match $pattern); $matches['OpenFile']}
$openfiles | Sort-Object -Unique | ForEach-Object { openfiles /disconnect /s $computerName /a * /op `"$_`"}


openfiles /query /s 'nas2-upm.matrix.gatech.edu' /v 

openfiles /disconnect /s 'nas2-upm.matrix.gatech.edu' /a * /op "C:\vol\vlab_upm1\DeleteMe"



#delete files
Remove-Item –path '\\nas2-upm.matrix.gatech.edu\vlab_upm1\DeleteMe\FslogixProfiles-BAD' –recurse -force
rm -Force -Recurse '\\nas2-upm.matrix.gatech.edu\vlab_upm1\DeleteMe\FslogixProfiles-BAD'

Get-ChildItem -Path '\\nas2-upm.matrix.gatech.edu\vlab_upm1\DeleteMe\FslogixProfiles-BAD' -Include * -File -Recurse | foreach { $_.Delete()}

$files = gci '\\nas2-upm.matrix.gatech.edu\vlab_upm1\DeleteMe\FslogixProfiles-BAD'
$files | Remove-Item -force -recurse
$files | % { $_.Delete() }
