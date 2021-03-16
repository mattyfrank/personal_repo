netsh interface ip set address name="Local Area Connection" source=static addr=130.207.167.231 255.255.255.0 130.207.167.1 1


netsh interface ip set dns name="Local Area Connection" source=static 130.207.165.170 
netsh interface ip add dnsservers name="Local Area Connection" address=130.207.170.15


PAUSE