#SetComputerName
netdom renamecomputer %computername% /Newname:ComputerName
netdom computername %computername% /makeprimary:%computername%.testdomain.com

#Set DNS Search Suffix
reg add HKLM\System\currentcontrolset\services\tcpip\parameters /v “NV Domain” /d “ad.gatech.edu” /f
set suffix=ad.gatech.edu

#JoinDomain
add-computer -domainname ad.gatech.edu -oupath "OU=Servers,OU=_OIT,DC=ad,DC=gatech,DC=edu" -cred #ad\User #Creds

#Will require reboot here

#Force GPO
gpupdate /force

#Will require reboot here

#Extend OS Partition
diskpart   
list volume
select volume 2
extend 


#Create Local Account, and add it to Administrators, Add Domain Object to Administrators
net user /add #LocalUserAccount #Password
net localgroup administrators #ad\Object /add
net localgroup administrators #LocalUserAccount /add
#Verify Administrators
net localgroup administrators

#Enable Remote Desktop AND Firewall Rule. 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /d 0 /t REG_DWORD /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /d 1 /t REG_DWORD
netsh advfirewall firewall set rule group="remote desktop" new enable=yes


#Disable IPV6
#New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters -Name DisabledComponents -PropertyType DWord -Value "0xffffffff"


