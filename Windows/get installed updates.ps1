$colitem=gwmi win32_computersystem

foreach ($objitem in $colitem){
$objitem.name|out-file "\\prism.nas.gatech.edu\prism\34\matthew\patch_report.txt" -append }

$sttime=[DateTime]::now.adddays(-1)
$wus = new-object -com "Microsoft.Update.Searcher"
$wusgettotalhistorycount=$wus.GetTotalHistoryCount()
$colitem=$wus.QueryHistory(0,$wusgettotalhistorycount)|select title,date | where {$_.date -gt $sttime} foreach ($objitem in $colitem){ $strupdtitle=" - " + $objitem.title out-file "\\prism.nas.gatech.edu\girard\patch_report.txt" -input $strupdtitle -append } out-file "\\prism.nas.gatech.edu\girard\patch_report.txt" -input "" -append out-file "\\prism.nas.gatech.edu\girard\patch_report.txt" -input "" -append out-file "\\prism.nas.gatech.edu\girard\patch_report.txt" -input "" -append $a = new-object -comobject wscript.shell $b = $a.popup("Patch Report",0,"Complete",1)
