
 

Set ebsservers=130.207.165.240,130.207.165.241,130.207.165.242,130.207.165.243,130.207.165.244,130.207.165.245,130.207.165.246,130.207.165.247,130.207.165.248,130.207.160.13
Set servermanager=130.207.241.134,130.207.241.127,130.207.241.132,130.207.241.126
set aimgmt=130.207.167.0/24,143.215.16.0/20



REM EBS Ports
FOR /L %%I IN (7937,1,7945) DO netsh firewall add portopening protocol = TCP port = %%I name = EBS_TCP_%%I scope = CUSTOM addresses = %ebsservers%
netsh firewall add portopening protocol = UDP port = 7938 name = "EBS UDP 7938" mode = ENABLE scope = CUSTOM addresses = %ebsservers%




netsh firewall add portopening protocol = TCP port = 445 name = "Port 445 TCP" mode = ENABLE scope = CUSTOM addresses = %servermanager%



REM Server Managment (If needed)
netsh firewall set icmpsetting 8 ENABLE
netsh firewall set service type = remotedesktop mode = ENABLE scope = CUSTOM addresses =%aimgmt%

