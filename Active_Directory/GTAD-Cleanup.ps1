#https://arnaudloos.com/AD-Health-Check/

##Requires PSWriteHTML Module to output html files
#Install-Module PSWriteHTML -Force


[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter()]
    [string]
    $Path = "C:\GTAD_Cleanup",

    [Parameter()]
    [string]
    $logpath = "$Path\Logs",

    [Parameter()]
    [string]
    $logfile = "$Path\Logs\GTAD-Cleanup-$(get-date -f yyyy-MM-dd-HH.mm).txt",

    [Parameter()]
    [string]
    $age = "365"

    )

    #initialize arraylists
    #users
    $TotalStaleUsers = [System.Collections.ArrayList]@()
    $TotalDisabledUsers = [System.Collections.ArrayList]@()
    $TotalAdminCountUsers = [System.Collections.ArrayList]@()
    $TotalNeverUsed = [System.Collections.ArrayList]@()

    #devices
    $TotalWinDevices = [System.Collections.ArrayList]@()
    $TotalAllDevices = [System.Collections.ArrayList]@()
    $TotalDisabledDevices = [System.Collections.ArrayList]@()
    
    #objects
    $TotalGroups = [System.Collections.ArrayList]@()
    $TotalOUs = [System.Collections.ArrayList]@()


 #Setup logging
 If(!(Test-Path $logpath))
 {
  Write-Host -ForegroundColor DarkYellow "Log path not found, creating log file."
  New-Item $logpath -ItemType Directory
 }

  
#import PSWrite
If (!(Get-module PSWriteHTML))
{
    Write-host -ForegroundColor DarkYellow "Importing PSWriteHTML."
    Import-Module PSWriteHTML
}

#import ActiveDirectory
If (!(Get-module ActiveDirectory)) 
{
    Write-host -ForegroundColor DarkYellow "Importing AD Module."
    Import-Module ActiveDirectory
} 


$UserInput = $(Write-Host -ForegroundColor Green -NoNewline "Do you want to cleanup GTAD today? (y / n)"; Read-Host)
    Switch ($UserInput) 
    { 
        Y {Write-host -ForegroundColor Green "Yes, let's get started..."; $PublishSettings=$true} 
        N {Write-Host -ForegroundColor Red "No, maybe another day..."; exit} 
        Default {Write-Host "Default, Canceling"; exit}
    }


#Start Logging
Write-host -ForegroundColor DarkGray "Start Logging"
Start-Transcript -Path $logfile


#Get Top Level OUs
Write-Host -ForegroundColor DarkGray "Searching: for Top Level OUs in ad.gatech.edu"
$TopLevelOU = Get-ADOrganizationalUnit -Filter * -SearchBase "DC=ad,DC=gatech,DC=edu" -SearchScope OneLevel


#Region StaleUserAccount (work in progress)
$userinput = $(Write-Host "Do you want to cleanup User Accounts? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{ 
    Write-host -ForegroundColor Gray "this could take a while..."
    Write-Host ""
    Write-Host -ForegroundColor DarkGray "User Account Cleanup."
    Write-Host "" 
    
    foreach ($OU in $TopLevelOU)
    {
        $OUname = $OU.Name
        $OUpath = "$Path\$OUname"
        If(!(Test-Path $OUpath))
        {
            Write-Host -ForegroundColor DarkYellow "Creating Directory for:" $OUname
            New-Item -ItemType Directory $OUpath
         }

        #Variable for the common properties below
        $usrprprts = @('Name','UserPrincipalName','Created','LastLogonDate','PasswordLastSet','Enabled')
        
        Write-Host -ForegroundColor DarkGray "Searching:" $OU.DistinguishedName
    
        ##Verify OUs that we should bypass. How to search for secondary accounts.

        #search for stale accounts
        Write-Host -ForegroundColor DarkGray "Searching: for enabled stale user accounts."
        $StaleUsers = Get-ADUser -Filter * -Properties $usrprprts -SearchBase $OU.DistinguishedName | Where-Object {($_.LastLogonDate -lt (Get-Date).AddDays(-$age)) -and ($_.enabled -like "true")} | select $usrprprts
    
        #search for disabled accounts
        Write-Host -ForegroundColor DarkGray "Searching: for disabled user accounts."
        $DisabledUsers = Get-ADUser -Filter * -Properties $usrprprts -SearchBase $OU.DistinguishedName | Where-Object {($_.enabled -like "false")} | select $usrprprts

        #get account that has never logged in
        Write-Host -ForegroundColor DarkGray "Searching: for user accounts that have never been used."
        $NeverUsed = Get-ADUser -Filter * -Properties $usrprprts -SearchBase $OU.DistinguishedName | Where-Object {($_.LastLogonDate -eq $null) -and ($_.enabled -like "true")} | select $usrprprts

        #get accounts with admincount =1
        Write-Host -ForegroundColor DarkGray "Searching: for user accounts with admincount flag."
        $Admin1 = Get-ADUser -Filter * -Properties $usrprprts -SearchBase $OU.DistinguishedName | where {$_.AdminCount -eq 1} | select $usrprprts

        Start-Sleep -Seconds 1
        
        $TotalStaleUsers += $StaleUsers
        $TotalDisabledUsers += $DisabledUsers
        $TotalNeverUsed += $NeverUsed
        $TotalAdminCountUsers += $Admin1

        #output computer objects
        if ($StaleUsers.count -ne 0)  ###greater than -gt > 0? 
        {  
            Write-Host ""
            Write-Host -ForegroundColor Cyan "Stale Users in" $OUname
            #$StaleUsers.UserPrincipalName | Write-Host -ForegroundColor Yellow 
            #$StaleUsers | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath  "$OUpath\$OUname-Stale_UserAccounts.html"
            Write-Host -ForegroundColor Magenta $StaleUsers.count "Stale User Objects in" $OUname
        }#End StaleUsers

        if ($DisabledUsers.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "Disabled User Objects in" $OUname
            #$DisabledUsers.UserPrincipalName | Write-Host -ForegroundColor Yellow 
            #$DisabledUsers | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath  "$OUpath\$OUname-Disabled-UserAccounts.html"
            Write-Host -ForegroundColor Magenta $DisabledUsers.count "Disabled Accounts in" $OUname
        }#End DisabledUsers

        if ($NeverUsed.count -ne 0)
        { 
            Write-Host ""
            Write-Host -ForegroundColor Cyan "User Objects Never Used in" $OUname
            #$NeverUsed.UserPrincipalName | Write-Host -ForegroundColor Yellow 
            #$NeverUsed | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath  "$OUpath\$OUname-UserAccounts_NeverUsed.html"
            Write-Host -ForegroundColor Magenta $NeverUsed.count "Accounts Never Used in" $OUname
        }#End NeverUsed

        if ($Admin1.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "AdminCount -eq 1 Flagged Accounts in" $OUname
            $Admin1.UserPrincipalName | Write-Host -ForegroundColor Yellow 
            #$Admin1 | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath  "$OUpath\$OUname_Admin_UserAccounts.html"
            Write-Host -ForegroundColor Magenta $Admin1.count "Admin Accounts in" $OUname
        }#End Admin

    Write-Host ""

 } #End ForEach

#Option - Write Total* to $path\file. 
#$TotalAdminCountUserst | Export-Csv -path $Path\Total-Admin-Users.csv

#print total number of devices
Write-Host ""
Write-Host -ForegroundColor Green $TotalStaleUsers.Count "Stale User Objects in the domain."
Write-Host -ForegroundColor Green $TotalDisabledUsers.Count "Disabled User Objects in the domain."
Write-Host -ForegroundColor Green $TotalNeverUsed.Count "User Objects NeverUsed in the domain."
Write-Host -ForegroundColor Green $TotalAdminCountUsers.Count "All AdminCount1 Objects in the domain."
Write-Host ""
Write-Host "------------------------------"

}#End UserCleanup

#EndRegion StaleUserAccount (work in progress)

#############################


#Region ComputerObjectCleanup

$userinput = $(Write-Host "Do you want to cleanup Computer Objects? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{ 
    Write-host -ForegroundColor Gray "make sure you backup Bitlocker Keys before you delete any computer objects..."
    Write-Host ""
    Write-Host -ForegroundColor Gray "Computer Object Cleanup"
    Write-Host "" 
    
    foreach ($OU in $TopLevelOU)
    {
        $OUname = $OU.Name
        $OUpath = "$Path\$OUname"
        
        If(!(Test-Path $OUpath))
        {
            Write-Host -ForegroundColor DarkYellow "Creating Directory for:" $OUname
            New-Item -ItemType Directory $OUpath
         }
         
        Write-Host -ForegroundColor DarkGray "Searching:" $OU.DistinguishedName
        
        #Variable for the common properties below
        $cmptrprpts = @('Name','CanonicalName','Created','LastLogonDate','OperatingSystem','Enabled')
        
        #search for stale devices
        Write-Host -ForegroundColor DarkGray "Searching: for stale computer objects."
        $AllStaleDevices = Get-ADComputer -Filter * -SearchBase $OU.DistinguishedName -SearchScope Subtree -Properties $cmptrprpts | Where-Object {($_.LastLogonDate -lt (Get-Date).AddDays(-$age))} | select $cmptrprpts
        #-and  ($_.PasswordLastSet -lt (Get-Date).AddDays(-$age))} 
    
        #filter windows devices from stale devices
        Write-Host -ForegroundColor DarkGray "Searching: for stale Windows devices."
        $StaleWinDevices = $AllStaleDevices | Where-Object {($_.operatingsystem -like "Windows*")} 
        #| select Name,CanonicalName,Created,LastLogonDate,OperatingSystem,Enabled
        # -and ($_.LastLogonDate -lt (Get-Date).AddDays(-$age))} 

        #search for disabled devices
        Write-Host -ForegroundColor DarkGray "Searching: for disabled computer objects."
        $DisabledObjects = Get-ADComputer -Filter * -SearchBase $OU.DistinguishedName -SearchScope Subtree -Properties $cmptrprpts | where {($_.Enabled) -like "False"} | select $cmptrprpts

        Start-Sleep -Seconds 1
        
        $TotalAllDevices += $AllStaleDevices
        $TotalWinDevices += $StaleWinDevices
        $TotalDisabledDevices += $DisabledObjects
        
        if ($AllStaleDevices.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "Stale Devices in" $OUname
            #$AllStaleDevices.name | Write-Host -ForegroundColor yellow 
            $AllStaleDevices | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath "$OUpath\$OUname-stale-computer-objects.html"
            Write-Host -ForegroundColor Magenta $AllStaleDevices.count "Stale (All) Devices in " $OUname
        }#End StaleDevices

        if ($StaleWinDevices.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "Stale Windows Computer Objects in $OUname"
            $StaleWinDevices.Name | Write-Host -ForegroundColor Yellow
            $StaleWinDevices | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath "$OUpath\$OUname-Stale-Windows-Devices.html"
            Write-Host -ForegroundColor Magenta $StaleWinDevices.Count "Stale (Windows) Devices in " $OUname
        }#End WinStale
        
        if ($DisabledObjects.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "Disabled Computer Objects in $OUname"    
            #$DisabledObjects.name | Write-Host -ForegroundColor yellow
            $DisabledObjects | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath "$OUpath\$OUname-disabled-computer-objects.html"
            Write-Host -ForegroundColor Magenta $DisabledObjects.count "Disabled Devices in " $OUname
        }#End Disabled
 
        Write-Host ""

    }#End ForEach

#Option - Write Total* to $path\file.
$TotalWinDevices | Export-CSV "$Path\Stale-Windows-Devices.csv"

#print total number of devices
Write-Host ""
Write-Host -ForegroundColor Green $TotalWinDevices.Count "Stale Windows Computer Objects in the domain."
Write-Host -ForegroundColor Green $TotalAllDevices.Count "All Stale Computer Objects in the domain."
Write-Host -ForegroundColor Green $TotalDisabledDevices.count "All Disabled Computer Objects in the domain."
Write-Host "------------------------------"

Write-Host ""
}#EndComputer

#EndRegion ComputerObjectCleanup

############################

#Region EmptyGroups

$userinput = $(Write-Host "Do you want to Cleanup Empty Groups? y/n" -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{ 
    Write-host -ForegroundColor Gray "how many groups do you think we have?"
    Write-Host ""
    Write-Host -ForegroundColor Gray "Empty Active Directory Groups" 
    Write-Host ""
    foreach ($OU in $TopLevelOU)
    {    
        $OUname = $OU.Name
        $OUpath = "$Path\$OUname"
        If(!(Test-Path $OUpath))
        {
            Write-Host -ForegroundColor DarkYellow "Creating Directory for:" $OUname
            New-Item -ItemType Directory $OUpath
         }
        Write-Host -ForegroundColor DarkGray "Searching:" $OU.DistinguishedName
        $grpprpts = @('Members','Name','CanonicalName','Created','Modified')

        ##Search for groups in with no members
        Write-Host -ForegroundColor DarkGray "Searching: for empty groups."
        $EmptyGroups = Get-ADGroup -Filter * -SearchBase $OU.DistinguishedName -Properties $grpprpts | where {-not $_.members} | select Name,CanonicalName,Created,Modified
        #datacreated?

        #count empty groups
        Start-Sleep -Seconds 1
        $TotalGroups += $EmptyGroups
    
        if ($EmptyGroups.count -ne 0)
        {
            Write-Host -ForegroundColor DarkGray "Empty AD Groups in" $OUname
            #$EmptyGroups.Name | Write-Host -ForegroundColor Yellow
            #$EmptyGroups | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  "$OUpath\$OUname-empty-groups.html"
            Write-Host -ForegroundColor Magenta $EmptyGroups.count "Empty Ad Groups in" $OUname
        }#End EmptyGroups
    
        #Print to screen 
        Write-Host ""

        }#End ForEach 

#Option - Write Total* to $path\file.
#$TotalGroups | Export-CSV "$path\Empty-Grups.csv"

#Print total number of groups
Write-Host ""
Write-Host -ForegroundColor Yellow $TotalGroups.Count "Total Empty Groups"
Write-Host "------------------------------"
Write-Host ""

}#End Groups

#EndRegion EmptyGroups

############################

#Region BlockInheritance
$userinput = $(Write-Host "Do you want to sniff out all the block inheritance? y/n" -ForegroundColor Green -NoNewline; Read-Host)
if ( $userinput -eq 'y')
{ 
    Write-host -ForegroundColor Gray "What are we waiting for? Lets get to it!"
    Write-Host ""
    Write-Host -ForegroundColor Gray "AD Groups with Block Inheritance"
    Write-Host "" 
    foreach ($OU in $TopLevelOU)
    {    
        $OUname = $OU.Name
        $OUpath = "$Path\$OUname"
        If(!(Test-Path $OUpath))
        {
            Write-Host -ForegroundColor DarkYellow "Creating Directory for:" $OUname
            New-Item -ItemType Directory $OUpath
        }
        Write-Host -ForegroundColor DarkGray "Searching:" $OU.DistinguishedName
    
        ##Search for OUs with blocking inheritance
        Write-Host -ForegroundColor DarkGray "Searching: for OUs with Block Inheritance."
        $BlockedOU = Get-ADOrganizationalUnit  -Filter * -SearchBase $OU.DistinguishedName | where {(Get-GPInheritance $_.DistinguishedName).GpoInheritanceBlocked -eq "Yes"} | select Name,DistinguishedName

        Start-Sleep -Seconds 1
        $TotalOUs += $BlockedOU
    
        if ($BlockedOU.count -ne 0)
        {
            Write-Host ""
            Write-Host -ForegroundColor Cyan "OUs with Block Inheritance in" $OUname 
            $BlockedOU.name | Write-Host -ForegroundColor Yellow
            #$BlockedOU | Out-HtmlView -PagingLength 50 -PreventShowHTML -FilePath  "$OUpath\$OUname-blocked-OUs.html"
            Write-Host -ForegroundColor Magenta $BlockedOU.count "Blocked OUs in" $OU.Name
        }#End 

        #Print to screen
        Write-Host ""

    }#End ForEach

    #Option - Write Total* to $path\file.
    #$TotalOUs | Export-CSV "$paths\Blocked-OUs.csv"

    #Print total number of OUs
    Write-Host ""
    Write-Host -ForegroundColor Green $TotalOUs.Count "Total number of OUs with BlockInheritance."
    Write-Host "------------------------------"
    Write-Host ""

} #End BlockInheritance

#EndRegion BlockInheritance

############################

#Region GPOs
$userinput = $(Write-Host "Are you still there? (Y/N) (I'm guessng you arent...)" -ForegroundColor Green -NoNewline; Read-Host)
    Switch ($userinput) 
    { 
        Y {Write-host "Whew; we are almost done. ";   } 
        N {Write-Host "Nope, over it... "; exit       } 
        Default {Write-Host "Default, Canceling"; exit}
    }#haha


$userinput = $(Write-Host "Do you want to review GPOs? y/n " -ForegroundColor Green -NoNewline; Read-Host)
if ($userinput -eq 'y')
{ 
    Write-host -ForegroundColor Gray "What are we waiting for? Lets get to it! "
    Write-Host ""
    $gpprpts = @('DisplayName','CreationTime','Owner','Id')

    #GPOs that are enforced
    Write-Host -ForegroundColor Cyan "Searching for Enforced GPOs."
    $EnforcedGPOs = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Foreach {$_.GPOLinks } | select DisplayName,Enforced,Target,CreationTime,Owner,Id | Where {$_.Enforced -like "True"} 
    $EnforcedGPOs | select $gpprpts | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  $Path\enforced-gpos.html
    write-host -ForegroundColor Yellow $EnforcedGPOs.count "Enforced GPOs"
    Write-Host ""

    #GPOs that are linked but disabled
    Write-Host -ForegroundColor Cyan "Searching for Linked, but Disabled GPOs."
    $DisabledGPOs = (Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Foreach {$_.GPOLinks } | select Enabled,Target,CreationTime,Owner,Id | Where {$_.Enabled -like "False"})
    $DisabledGPOs | select $gpprpts| Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  $Path\disabled-gpos.html
    write-host -ForegroundColor Yellow $DisabledGPOs.count "Disabled GPOs"
    Write-Host ""

    #Get ALL GPOs that are Unlinked
    Write-Host -ForegroundColor Cyan "Searching for UnLinked, GPOs."
    $UNLINKED = Get-GPO -All |Where-Object { $_ | Get-GPOReport -ReportType XML| Select-String -NotMatch "<LinksTo>" }
    $UNLINKED | select $gpprpts | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  $Path\unlinked-gpos.html
    write-host -ForegroundColor Yellow $UNLINKED.count "UnLinked GPOs"
    Write-Host ""

    #GPOs with Version 0
    Write-Host -ForegroundColor Cyan "Searching for Empty GPOs."
    $EmptyGPOs = (Get-GPO -All | where {$_.Computer.DSVersion -eq 0 -and $_.User.DSVersion -eq 0})
    $EmptyGPOs | select $gpprpts | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  $Path\empty-gpos.html
    write-host -ForegroundColor Yellow $EmptyGPOs.count "Empty GPOs"
    Write-Host ""

    #Windows 2008 initial release date February 4, 2008 (4768)
    Write-Host -ForegroundColor Cyan "Searching for old GPOs."
    $Win2008ReleaseDate = "02/04/2008 12:00pm"
    $oldGPOs = Get-GPO -all | where {$_.CreationTime -lt ($Win2008ReleaseDate)}
    $oldGPOs | select $gpprpts | Out-HtmlView -PagingLength 50 -PreventShowHTML  -FilePath  $Path\old-gpos.html
    write-host -ForegroundColor Yellow $OldGPOs.count "Old GPOs"
    Write-Host ""
}#End GPOs

#EndRegion GPOs

Write-Host -ForegroundColor Green "That's all folk's"
Write-Host -ForegroundColor Gray "All logs and reports are located: " $path

###########################

#End Logs
Stop-Transcript