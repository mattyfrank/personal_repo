###PS '.\RESTORE GPO WIP.ps1' -Name "AE_F2015_Citrix_Profile_Mgt___{a1276950-738e-4dd3-948b-b99740b1c26b}"  -Path "C:\GPO-Backups\Backups\2021-02-08-18" -Server gtad01.ad.gatech.edu



[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$True,Position=0,
    HelpMessage="Enter the folder name of the GPO that needs to be restored")]
    [alias("GroupPolicy","GPO","FolderName")]
    [string]
    $Name ,

    [Parameter()]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Domain = $env:USERDNSDOMAIN,

    # Specify aliases for the Server parameter and support tab completion for domain controller names.
    [Parameter()]
    [Alias("DomainController","DC")]
    [ArgumentCompleter( {
        param ( $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters )
        $possibleValues = @{ Server = (Get-ADDomainController -Filter *).Hostname }
        if ($fakeBoundParameters.ContainsKey('Type')) { $possibleValues[$fakeBoundParameters.Type] | Where-Object { $_ -like "$wordToComplete*" } }
        else { $possibleValues.Values | ForEach-Object {$_} }
    } )]
    $Server
    )

    #Variable to hold the concatenated full original path
    $FullOriginalPath = $path + "\" + $Name

    #Create temp variables to hold just the GUID two different ways
    $TempFolderName = $Name -replace '^.+_{3}'
    $GUID = $TempFolderName -replace '^\{|\}$'

    #Create a temp variable to hold the temporary updated full path
    $FullTempPath = $path + "\" + $TempFolderName


    $Connection = Test-path $FullOriginalPath

    If(!($Connection)) {
        Write-Warning "Folder " $FullOriginalPath "is not reachable!"
        } #end if

    Else {

        #Rename the specified GPO folder to just the GUID
        Rename-item  $FullOriginalPath -newname $FullTempPath

        Restore-GPO -BackupID $GUID -Path $path -Domain $Domain -Server $Server

        #Rename the folder from a GUID back to the original folder name
        Rename-item  $FullTempPath -newname $FullOriginalPath

    } #end else


 #end of function