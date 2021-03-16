function Get-UnlinkedGPOs {
    function IsNotLinked($xmldata){
        If ($xmldata.GPO.LinksTo -eq $null) { 
            Return $true 
        } 
        Return $false 
    } 
 
    $unlinkedGPOs = @() 

    Get-GPO -All | ForEach { $gpo = $_ ; $_ | Get-GPOReport -ReportType xml | ForEach { If( IsNotLinked([xml]$_) ) {$unlinkedGPOs += $gpo} }} 
 
    return $unlinkedGPOs
}