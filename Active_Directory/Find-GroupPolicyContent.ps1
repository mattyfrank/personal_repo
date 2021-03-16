#####################################################
#
#   Find-GroupPolicyContent
#
#####################################################




Import-Module ActiveDirectory

$GPOs = Get-GPO -All -Domain ad.gatech.edu

$PolicyHits = [System.Collections.ArrayList]@()

#Export-Csv -InputObject $PolicyHits -Path .\PolicyHits1.csv -NoTypeInformation -Force

foreach ($gpo in $GPOs) {
        $GPOReport = Get-GPOReport -Guid $gpo.Id -ReportType Xml
        if (($GPOReport -match '<q2:Name>DNS servers</q2:Name>') -and (($GPOReport -match '<q2:Value>130.207.165.170</q2:Value>') -or ($GPOReport -match '<q2:Value>143.215.143.72</q2:Value>'))) {
            Write-Host "Match found in "$gpo.DisplayName
            $PolicyHits.Add($gpo)
        }
}

Export-Csv -InputObject $PolicyHits -Path ~\Desktop\PolicyHits-New.csv -NoTypeInformation -Force