
set ctx-appservers = 130.207.240.165-130.207.240.169,130.207.240.200-130.207.240.201

netsh advfirewall firewall add rule name="CTX-EIS-Appservers" dir=in action=allow protocol=TCP localport=1433 remoteport=any remoteip=130.207.240.165-130.207.240.169,130.207.240.200-130.207.240.201
set operations = 130.207.161.14/31, 130.207.165.74, 130.207.166.15, 130.207.166.16/31, 130.207.166.55, 130.207.166.60

netsh advfirewall firewall add rule name="Swarm-SQLmon" dir=in action=allow protocol=TCP localport=1433 remoteport=any remoteip=%operations%
