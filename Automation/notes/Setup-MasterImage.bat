echo off
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

::ENTER YOUR CODE BELOW:

::CreateLocal Admin Account::
net user /add dilbert gtadr0x0rs!
net localgroup administrators dilbert /add
wmic useraccount where “Name=dilbert” set PasswordExpires=false

::DiskPart To Extend Volume2::
DISKPART /s diskpart.txt

::Make DIrectory and Copy Install Files::
md "C:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\Citrix\Public\VDA\1912" "c:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\Citrix\Public\Support Tools\CitrixOptimizer - v2.6.0.118.zip" "C:\Installs
copy "\\depot.matrix.gatech.edu\vlab_depot1\Nvidia\4.10\370.41_grid_win10_server2016_64bit_international" "C:\Installs"
copy "\\depot.matrix.gatech.edu\vlab_depot1\VMWare\Vmware Tools\VMware-Tools-windows-11.0.5-15389592" "C:Installs"





