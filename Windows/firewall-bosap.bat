set ctx-appservers = 130.207.240.0/26,130.207.240.64/27,130.207.240.128/25,130.207.241.167,143.215.40.208/28
set ctx-appservers = 130.207.240.0-130.207.240.95, 130.207.240.128-130.207.240.255, 130.207.241.167, 143.215.40.208-143.215.40.223
set bus-obj-project = 130.207.45.16,130.207.51.111,130.207.51.124,130.207.51.129,130.207.163.37,130.207.163.40,130.207.163.51,130.207.163.61,130.207.163.62,130.207.163.63,130.207.163.70,130.207.163.89,130.207.163.98,130.207.163.134,130.207.163.238,130.207.164.11,130.207.164.22,130.207.164.23,130.207.164.39,130.207.164.51,130.207.164.59,130.207.164.62,130.207.164.78,130.207.164.105,130.207.164.112,130.207.164.120,130.207.164.121,130.207.164.125,130.207.164.129,130.207.164.151,130.207.164.154,130.207.164.190,130.207.240.0/26,130.207.240.64/27,130.207.240.75



netsh advfirewall firewall add rule name="Bosap Netfwcfg - ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="Bosap Netfwcfg - http https ports TCP" dir=in action=allow protocol=TCP localport="80,443" remoteip=any
netsh advfirewall firewall add rule name="Bosap Netfwcfg - 6400-6430" dir=in action=allow protocol=TCP localport=6400-6430 remoteport= any remoteip=130.207.240.64-130.207.240.95
netsh advfirewall firewall add rule name="Bosap Netfwcfg - ctx-appservers" dir=in action=allow protocol=TCP localport=1024-65535 remoteport=any remoteip=130.207.240.0/26,130.207.240.64/27,130.207.240.128/25,130.207.241.167,143.215.40.208/28
netsh advfirewall firewall add rule name="Bosap Netfwcfg - bus-obj-project - all ip" dir=in action=allow protocol=TCP localport=any remoteport=any remoteip=130.207.45.16,130.207.51.111,130.207.51.124,130.207.51.129,130.207.163.37,130.207.163.40,130.207.163.51,130.207.163.61,130.207.163.62,130.207.163.63,130.207.163.70,130.207.163.89,130.207.163.98,130.207.163.134,130.207.163.238,130.207.164.11,130.207.164.22,130.207.164.23,130.207.164.39,130.207.164.51,130.207.164.59,130.207.164.62,130.207.164.78,130.207.164.105,130.207.164.112,130.207.164.120,130.207.164.121,130.207.164.125,130.207.164.129,130.207.164.151,130.207.164.154,130.207.164.190,130.207.240.0/26,130.207.240.64/27,130.207.240.75
