#Script to delete batch of AD DNS Records. 

#Provide a List of DNS Records & Get Content of List

$NodesToDelete = Get-Content C:\Users\UserName\Desktop\DNS_Delete.txt

#Set to DNS Server (gtad01)

$DNSServer = "gtad01.ad.gatech.edu"

#Set to AD Zone (AD.gatech.edu)

$ZoneName = "ad.gatech.edu"

foreach ($node in $NodesToDelete) {

   # Format List CName only

    $nodeCN = ($node.Split("."))[0]

    $NodeDNS = $null

    $NodeDNS = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $nodeCN -RRType A

    if($NodeDNS -eq $null){

        Write-Host "No DNS record found"

    } else {

        Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeDNS -Force

    }

}
