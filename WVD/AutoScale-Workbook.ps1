### https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-scaling-script ###

Login-AzAccount
Connect-AzAccount 
Connect-AzureAD
Select-AzSubscription 'Campus Production'


New-Item -ItemType Directory -Path "C:\Temp" -Force
Set-Location -Path "C:\Temp"
$Uri = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/wvd-templates/wvd-scaling-script/CreateOrUpdateAzAutoAccount.ps1"
# Download the script
Invoke-WebRequest -Uri $Uri -OutFile ".\CreateOrUpdateAzAutoAccount.ps1"

$Params = @{
     "AADTenantId"           = "482198bb-ae7b-4b25-8b7a-6d7f32faa083"   # Optional. If not specified, it will use the current Azure context
     "SubscriptionId"        = "c1835977-39e7-4415-a092-a77866f5afb8"              # Optional. If not specified, it will use the current Azure context
     "UseARMAPI"             = $true
     "ResourceGroupName"     = "WVD-HostGroup-General"                # Optional. Default: "WVDAutoScaleResourceGroup"
     "AutomationAccountName" = "wvd-sa"            # Optional. Default: "WVDAutoScaleAutomationAccount"
     "Location"              = "East US"
     "WorkspaceName"         = "OIT-WVD-LogAnalytics"       # Optional. If specified, Log Analytics will be used to configure the custom log table that the runbook PowerShell script can send logs to
}

.\CreateOrUpdateAzAutoAccount.ps1 @Params




#Results-
<#
.\CreateOrUpdateAzAutoAccount.ps1 @Params
VERBOSE: Performing the operation "Creating Deployment" on target "WVD-HostGroup-General".
VERBOSE: 11:40:32 AM - Template is valid.
VERBOSE: 11:40:33 AM - Create template deployment 'runbookCreationTemplate'
VERBOSE: 11:40:33 AM - Checking deployment status in 5 seconds
VERBOSE: 11:40:38 AM - Resource Microsoft.Automation/automationAccounts/runbooks 'wvd-sa/WVDAutoScaleRunbookARMBased' provisioning status is succeeded
VERBOSE: 11:40:38 AM - Resource Microsoft.Automation/automationAccounts 'wvd-sa' provisioning status is succeeded
VERBOSE: Performing the operation "For security purposes, the URL of the created webhook will only be viewable in the output of this command. No other commands will return the webhook URL. Make sure 
to copy down the webhook URL from this command's output before closing your PowerShell session, and to store it securely." on target "WVDAutoScaleWebhookARMBased".
Automation Account Webhook is created with name 'WVDAutoScaleWebhookARMBased'


Value                 : https://58a72ccc-9c6b-40c2-b06e-f0be56774c79.webhook.eus.azure-automation.net/webhooks?token=XUK5MYuSqyqWpvf%2blk8rFZ40EXwamWe8d%2bp8BoTnKFk%3d
Encrypted             : False
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : WebhookURIARMBased
CreationTime          : 1/20/2021 11:40:44 AM -05:00
LastModifiedTime      : 1/20/2021 11:40:44 AM -05:00
Description           : 

Webhook URI stored in Azure Automation Acccount variables
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : Az.Accounts
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:41:00 AM -05:00
LastModifiedTime      : 1/20/2021 11:41:00 AM -05:00
ProvisioningState     : Creating

Waiting for module 'Az.Accounts' to get imported into Automation Account Modules ...
Waiting for module 'Az.Accounts' to get imported into Automation Account Modules ...
Waiting for module 'Az.Accounts' to get imported into Automation Account Modules ...
Successfully imported module 'Az.Accounts' into Automation Account Modules
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : Az.Compute
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:44:31 AM -05:00
LastModifiedTime      : 1/20/2021 11:44:31 AM -05:00
ProvisioningState     : Creating

Waiting for module 'Az.Compute' to get imported into Automation Account Modules ...
Waiting for module 'Az.Compute' to get imported into Automation Account Modules ...
Waiting for module 'Az.Compute' to get imported into Automation Account Modules ...
Waiting for module 'Az.Compute' to get imported into Automation Account Modules ...
Successfully imported module 'Az.Compute' into Automation Account Modules
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : Az.Resources
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:46:41 AM -05:00
LastModifiedTime      : 1/20/2021 11:46:42 AM -05:00
ProvisioningState     : Creating

Waiting for module 'Az.Resources' to get imported into Automation Account Modules ...
Waiting for module 'Az.Resources' to get imported into Automation Account Modules ...
Waiting for module 'Az.Resources' to get imported into Automation Account Modules ...
Successfully imported module 'Az.Resources' into Automation Account Modules
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : Az.Automation
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:48:18 AM -05:00
LastModifiedTime      : 1/20/2021 11:48:18 AM -05:00
ProvisioningState     : Creating

Waiting for module 'Az.Automation' to get imported into Automation Account Modules ...
Waiting for module 'Az.Automation' to get imported into Automation Account Modules ...
Waiting for module 'Az.Automation' to get imported into Automation Account Modules ...
Successfully imported module 'Az.Automation' into Automation Account Modules
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : OMSIngestionAPI
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:49:55 AM -05:00
LastModifiedTime      : 1/20/2021 11:49:55 AM -05:00
ProvisioningState     : Creating

Waiting for module 'OMSIngestionAPI' to get imported into Automation Account Modules ...
Waiting for module 'OMSIngestionAPI' to get imported into Automation Account Modules ...
Waiting for module 'OMSIngestionAPI' to get imported into Automation Account Modules ...
Waiting for module 'OMSIngestionAPI' to get imported into Automation Account Modules ...
Successfully imported module 'OMSIngestionAPI' into Automation Account Modules
ResourceGroupName     : WVD-HostGroup-General
AutomationAccountName : wvd-sa
Name                  : Az.DesktopVirtualization
IsGlobal              : False
Version               : 
SizeInBytes           : 0
ActivityCount         : 0
CreationTime          : 1/20/2021 11:52:03 AM -05:00
LastModifiedTime      : 1/20/2021 11:52:03 AM -05:00
ProvisioningState     : Creating

Waiting for module 'Az.DesktopVirtualization' to get imported into Automation Account Modules ...
Waiting for module 'Az.DesktopVirtualization' to get imported into Automation Account Modules ...
Waiting for module 'Az.DesktopVirtualization' to get imported into Automation Account Modules ...
Successfully imported module 'Az.DesktopVirtualization' into Automation Account Modules
200
Log Analytics Workspace ID: b39f8bf5-4b44-42c9-8b20-927be8be87fe
Log Analytics Primary Key: /EdDBSd4jsVVaVjE6OiEwu5U2zPU2pRtezKpPNEE7Cy9CfnvDiePOpaWdhTa6JWf9VDy35SFlu0ULxbSNQlxZQ==
Azure Automation Account Name: wvd-sa
Webhook URI: https://58a72ccc-9c6b-40c2-b06e-f0be56774c79.webhook.eus.azure-automation.net/webhooks?token=XUK5MYuSqyqWpvf%2blk8rFZ40EXwamWe8d%2bp8BoTnKFk%3d
#>




New-Item -ItemType Directory -Path "C:\Temp" -Force
Set-Location -Path "C:\Temp"
$Uri = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/wvd-templates/wvd-scaling-script/CreateOrUpdateAzLogicApp.ps1"
# Download the script
Invoke-WebRequest -Uri $Uri -OutFile ".\CreateOrUpdateAzLogicApp.ps1"


$AADTenantId = (Get-AzContext).Tenant.Id
$AzSubscription = Get-AzSubscription -SubscriptionId 'c1835977-39e7-4415-a092-a77866f5afb8'
$ResourceGroup = Get-AzResourceGroup -Name 'WVD-HostGroup-General'
$WVDHostPool = Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Out-GridView -OutputMode:Single -Title "Select the host pool you'd like to scale"

$LogAnalyticsWorkspaceId = Read-Host -Prompt "If you want to use Log Analytics, enter the Log Analytics Workspace ID returned by when you created the Azure Automation account, otherwise leave it blank"
$LogAnalyticsPrimaryKey = Read-Host -Prompt "If you want to use Log Analytics, enter the Log Analytics Primary Key returned by when you created the Azure Automation account, otherwise leave it blank"
$RecurrenceInterval = Read-Host -Prompt "Enter how often you'd like the job to run in minutes, e.g. '15'"
$BeginPeakTime = Read-Host -Prompt "Enter the start time for peak hours in local time, e.g. 9:00"
$EndPeakTime = Read-Host -Prompt "Enter the end time for peak hours in local time, e.g. 18:00"
$TimeDifference = Read-Host -Prompt "Enter the time difference between local time and UTC in hours, e.g. +5:30"
$SessionThresholdPerCPU = Read-Host -Prompt "Enter the maximum number of sessions per CPU that will be used as a threshold to determine when new session host VMs need to be started during peak hours"
$MinimumNumberOfRDSH = Read-Host -Prompt "Enter the minimum number of session host VMs to keep running during off-peak hours"
$MaintenanceTagName = Read-Host -Prompt "Enter the name of the Tag associated with VMs you don't want to be managed by this scaling tool"
$LimitSecondsToForceLogOffUser = Read-Host -Prompt "Enter the number of seconds to wait before automatically signing out users. If set to 0, any session host VM that has user sessions, will be left untouched"
$LogOffMessageTitle = Read-Host -Prompt "Enter the title of the message sent to the user before they are forced to sign out"
$LogOffMessageBody = Read-Host -Prompt "Enter the body of the message sent to the user before they are forced to sign out"

$AutoAccount = Get-AzAutomationAccount | Out-GridView -OutputMode:Single -Title "Select the Azure Automation account"
$AutoAccountConnection = Get-AzAutomationConnection -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName | Out-GridView -OutputMode:Single -Title "Select the Azure RunAs connection asset"

$WebhookURIAutoVar = Get-AzAutomationVariable -Name 'WebhookURIARMBased' -ResourceGroupName $AutoAccount.ResourceGroupName -AutomationAccountName $AutoAccount.AutomationAccountName

$Params = @{
     "AADTenantId"                   = $AADTenantId                             # Optional. If not specified, it will use the current Azure context
     "SubscriptionID"                = $AzSubscription.Id                       # Optional. If not specified, it will use the current Azure context
     "ResourceGroupName"             = $ResourceGroup.ResourceGroupName         # Optional. Default: "WVDAutoScaleResourceGroup"
     "Location"                      = $ResourceGroup.Location                  # Optional. Default: "West US2"
     "UseARMAPI"                     = $true
     "HostPoolName"                  = $WVDHostPool.Name
     "HostPoolResourceGroupName"     = $WVDHostPool.ResourceGroupName           # Optional. Default: same as ResourceGroupName param value
     "LogAnalyticsWorkspaceId"       = $LogAnalyticsWorkspaceId                 # Optional. If not specified, script will not log to the Log Analytics
     "LogAnalyticsPrimaryKey"        = $LogAnalyticsPrimaryKey                  # Optional. If not specified, script will not log to the Log Analytics
     "ConnectionAssetName"           = $AutoAccountConnection.Name              # Optional. Default: "AzureRunAsConnection"
     "RecurrenceInterval"            = $RecurrenceInterval                      # Optional. Default: 15
     "BeginPeakTime"                 = $BeginPeakTime                           # Optional. Default: "09:00"
     "EndPeakTime"                   = $EndPeakTime                             # Optional. Default: "17:00"
     "TimeDifference"                = $TimeDifference                          # Optional. Default: "-7:00"
     "SessionThresholdPerCPU"        = $SessionThresholdPerCPU                  # Optional. Default: 1
     "MinimumNumberOfRDSH"           = $MinimumNumberOfRDSH                     # Optional. Default: 1
     "MaintenanceTagName"            = $MaintenanceTagName                      # Optional.
     "LimitSecondsToForceLogOffUser" = $LimitSecondsToForceLogOffUser           # Optional. Default: 1
     "LogOffMessageTitle"            = $LogOffMessageTitle                      # Optional. Default: "Machine is about to shutdown."
     "LogOffMessageBody"             = $LogOffMessageBody                       # Optional. Default: "Your session will be logged off. Please save and close everything."
     "WebhookURI"                    = $WebhookURIAutoVar.Value
}

.\CreateOrUpdateAzLogicApp.ps1 @Params

#Results
<#
.\CreateOrUpdateAzLogicApp.ps1 @Params
If you want to use Log Analytics, enter the Log Analytics Workspace ID returned by when you created the Azure Automation account, otherwise leave it blank: b39f8bf5-4b44-42c9-8b20-927be8be87fe
If you want to use Log Analytics, enter the Log Analytics Primary Key returned by when you created the Azure Automation account, otherwise leave it blank: /EdDBSd4jsVVaVjE6OiEwu5U2zPU2pRtezKpPNEE7Cy9CfnvDiePOpaWdhTa6JWf9VDy35SFlu0ULxbSNQlxZQ==
Enter how often you'd like the job to run in minutes, e.g. '15': 15
Enter the start time for peak hours in local time, e.g. 9:00: 7:00
Enter the end time for peak hours in local time, e.g. 18:00: 18:00
Enter the time difference between local time and UTC in hours, e.g. +5:30: -5:00
Enter the maximum number of sessions per CPU that will be used as a threshold to determine when new session host VMs need to be started during peak hours: 2
Enter the minimum number of session host VMs to keep running during off-peak hours: 1
Enter the name of the Tag associated with VMs you don't want to be managed by this scaling tool: 
Enter the number of seconds to wait before automatically signing out users. If set to 0, any session host VM that has user sessions, will be left untouched: 1800
Enter the title of the message sent to the user before they are forced to sign out: Automatic Shutdown in Progress 
Enter the body of the message sent to the user before they are forced to sign out: Please save your work and log off. If you would like please sign in again.
VERBOSE: Performing the operation "Creating Deployment" on target "WVD-HostGroup-General".
VERBOSE: 2:12:52 PM - Template is valid.
VERBOSE: 2:12:54 PM - Create template deployment 'logicAppCreationTemplate'
VERBOSE: 2:12:54 PM - Checking deployment status in 5 seconds
VERBOSE: 2:12:59 PM - Resource Microsoft.Logic/workflows 'Remote-Workspace_Autoscale_Scheduler' provisioning status is succeeded
Remote Workspace hostpool successfully configured with logic app scheduler
#>