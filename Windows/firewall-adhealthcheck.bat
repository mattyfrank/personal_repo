set adhealthcheck=130.207.160.194,130.207.174.90,130.207.241.160,130.207.241.162



'*********
netsh advfirewall firewall add rule name="Open rpc to adhealthcheck" dir=in action=allow protocol=UDP localport=135 remoteport=any  remoteip=%adhealthcheck%

netsh advfirewall firewall add rule name="Open rpc to adhealthcheck" dir=in action=allow protocol=TCP localport=135 remoteport=any  remoteip=%adhealthcheck%
netsh advfirewall firewall add rule name="Open rpc to adhealthcheck" dir=in action=allow protocol=TCP localport=49152-65535 remoteport=any remoteip=%adhealthcheck%


