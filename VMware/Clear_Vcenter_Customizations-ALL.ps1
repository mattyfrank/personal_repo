#Clear VM Customizations
Connect-VIServer -Server callisto.ad.gatech.edu
Remove-OSCustomizationSpec "*"
