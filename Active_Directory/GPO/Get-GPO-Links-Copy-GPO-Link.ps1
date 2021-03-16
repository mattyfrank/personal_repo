###Copy GPO Links
#Import the Group Policy module 
Import-Module GroupPolicy 

# Source for GPO links 
$Source = "OU=_XEN,DC=ad,DC=gatech,DC=edu" 
# Target where we want to set the new links 
$Target = "OU=_XEN,DC=ad,DC=gatech,DC=edu" 

# Get the linked GPOs 
$linked = (Get-GPInheritance -Target $source).gpolinks 

# Loop through each GPO and link it to the target 
foreach ($link in $linked) 
{ 
    $guid = $link.GPOId 
    $order = $link.Order 
    $enabled = $link.Enabled 
    if ($enabled) 
    { 
        $enabled = "Yes" 
    } 
    else 
    { 
        $enabled = "No" 
    } 
    # Create the link on the target 
    New-GPLink -Guid $guid -Target $Target -LinkEnabled $enabled -confirm:$false 
    # Set the link order on the target 
    Set-GPLink -Guid $guid -Target $Target -Order $order -confirm:$false 
}