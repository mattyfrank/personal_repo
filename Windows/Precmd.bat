echo "Start WSB Backup of Critical Volumes" >> WSBCreateBackup.log
rmdir r:\WindowsImageBackup /s /q
time /t >> C:\Scripts\WSBCreateBackup.log
date /t >> C:\Scripts\WSBCreateBackup.log
wbadmin start backup -backupTarget:r: -allCritical -quiet
echo "Complete WSB Backup of Critical Volumes" >>WSBCreateBackup.log
time /t >> C:\Scripts\WSBCreateBackup.log
date /t >> C:\Scripts\WSBCreateBackup.log
