diskpart 

pause

list disk

pause

select disk 0

pause 

clean

pause

create partition primary

pause

select partition 1

pause

format quick fs=ntfs label="os"

pause

assign

pause

active

pause

list volume