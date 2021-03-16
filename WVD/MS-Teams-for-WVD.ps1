#Optimize Teams for VDI
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f


#The ALLUSER=1 parameter is used only in VDI environments to specify a per-machine installation. 
#The ALLUSERS=1 parameter can be used in non-VDI and VDI environments. 

#Install MS Teams as per-user
#msiexec /i C:\Installs\Teams_windows_x64.msi /l*v C:\Installs\Teams-Install-Log.TXT

#Install Machine-Wide for NonPersistent VDI
#msiexec /i C:\Installs\Teams_windows_x64.msi /l*v C:\Installs\Teams-Install-Log.TXT ALLUSER=1

#Install Machine-Wide for VDI
msiexec /i C:\Installs\Teams_windows_x64.msi /l*v C:\Installs\Teams-Install-Log.TXT ALLUSERS=1

#Uninstall Teams
msiexec /passive /x C:\Installs\Teams_windows_x64.msi /l*v C:\Installs\Teams-uninstall-Log.TXT

#Install Teams Optimization WebSocket Service
msiexec /passive /i C:\Installs\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi /l*v C:\Installs\Teams-WebSocket-Log.TXT


#choco install teams- 
choco install microsoft-teams.install --install-arguments="'ALLUSERS=1'" -y

#choco uninstall teams
choco uninstall microsoft-teams.install -y

#List all ChocoPKG
choco list -l

#Install MS O365
$o365ConfigPath = "\\gt-repo.ad.gatech.edu\configs$\Office365AppsForEnt-Configuration.xml" 
choco upgrade office365proplus --params "/ConfigPath:$o365ConfigPath" -y
