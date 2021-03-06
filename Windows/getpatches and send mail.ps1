
#Clear-Variable strbody
$count = 0
$colitem=gwmi win32_computersystem
#$strbody = @()
foreach ($objitem in $colitem){
$compname = $objitem.name

$strbody = $compname + "`n"
}

$sttime=[DateTime]::now.adddays(-2)
$wus = new-object -com "Microsoft.Update.Searcher"
$wusgettotalhistorycount=$wus.GetTotalHistoryCount()
$colitem=$wus.QueryHistory(0,$wusgettotalhistorycount)|select title,date | where {$_.date -gt $sttime}

foreach ($objitem in $colitem){
$strupdtitle = " - " + $objitem.title
$strbody = $strbody + $strupdtitle +"`n"

}

 $messageParameters = @{                        
                Subject = $compname + " - patched and rebooted"                        
                Body = $strbody                 
                From = "matthew.franklin@oit.gatech.edu"                        
                To = "matthew.franklin@oit.gatech.edu"                        
                SmtpServer = "outbound.gatech.edu"                        
            }                        
Send-MailMessage @messageparameters 