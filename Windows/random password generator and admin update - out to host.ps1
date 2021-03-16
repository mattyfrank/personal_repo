

$admincheck = $null
$newadmincheck = $null


$objcompsys = Get-WmiObject -class Win32_ComputerSystem
$computerName = $objcompsys.Name
$ComputerDomain = $objcompsys.Domain
$fqdn =$computerName + "." + $ComputerDomain


$newlocaladmin = $computerName + "-admin"
$localadmin = "administrator"


function disableadministrator($localadmin,$adminisratorpassword,$fqdn) {
$objUser = [ADSI]("WinNT://$fqdn/$localadmin,user")
$objUser.Accountdisabled = $true
$objUser.setpassword($adminisratorpassword)
$objUser.setinfo()
$objUser = [ADSI]("WinNT://$fqdn/$localadmin")
$isadmindisabled = $objUser.Accountdisabled
$isadmindisabled = $isadmindisabled.ToString()
return $isadmindisabled
}

function addnewadmin($newlocaladmin,$newlocaladminpassword,$fqdn){
$objcomputer = [ADSI]("WinNT://$fqdn")
$newuser = $objcomputer.create("user","$newlocaladmin")
$newuser.setpassword($newlocaladminpassword)
$newuser.setinfo()

$objgroup = [ADSI]("WinNT://$fqdn/administrators,group")
$objgroup.add("WinNT://$newlocaladmin")


$objUser = [ADSI]("WinNT://$fqdn/$newlocaladmin,user")
$objUser.setpassword($newlocaladminpassword)
$objUser.setinfo()


$objUser = [ADSI]("WinNT://$fqdn/$newlocaladmin")
$isnewadmindisabled = $objUser.Accountdisabled
$isnewadmindisabled = $isnewadmindisabled.ToString()
return $isnewadmindisabled
}


function genrandompass{

do
{
$randompassver = $null
$randompassword = $null

$class1ver = $false
$class2ver = $false
$class3ver = $false
$class4ver = $false
$randompassver = $null
$randompassword = $null

$class1 = @()
For($i = 65;$i -le 90; $i++){ $class1 += [char]$i}

$class2 = @()
For($i = 97;$i -le 122; $i++){ $class2 += [char]$i}

$class3 = @()
For($i = 0;$i -le 9; $i++){ $class3 += $i}

$class4 = @('!','@','#','$','*')


$allclass = @()
$allclass = $class1 + $class2 + $class3 +$class4
$passwordlength = Get-Random -Minimum 11 -Maximum 17
For($i = 1;$i -le $passwordlength; $i++){ [string]$randompassword = $randompassword + (Get-Random -inputobject $allclass -Count 1)}

foreach($i in $class1){
If ($randompassword.Contains($i) -eq $true){
$class1ver = $true
}
}

foreach($i in $class2){
If ($randompassword.Contains($i) -eq $true){
$class2ver = $true
}
}

foreach($i in $class3){
If ($randompassword.Contains($i) -eq $true){
$class3ver = $true
}
}


foreach($i in $class4){
If ($randompassword.Contains($i) -eq $true){
$class4ver = $true
}
}

$randompassver = $class1ver -eq $class2ver -eq $class3ver -eq $class4ver

}
until($randompassver -eq $true)
return $randompassword
}






$adminisratorpassword = genrandompass
$newlocaladminpassword = genrandompass

$admincheck = disableadministrator $localadmin $adminisratorpassword $fqdn 
$newadmincheck = addnewadmin $newlocaladmin $newlocaladminpassword $fqdn 

if (($admincheck -eq "True") -and ($newadmincheck -eq "False")){
Write-Host "The user changes to $fqdn appear successful" -ForegroundColor Green
Write-Host "$fqdn - passwords:"
Write-Host "Admin password - $adminisratorpassword"
Write-Host "$newlocaladmin password - $newlocaladminpassword"
}
else{Write-Host "The user changes to $fqdn failed!" -ForegroundColor Red}



