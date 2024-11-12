<#
.SYNOPSIS
    Get-AzureUserLicensing

.LINK
    GitHub: https://github.com/MichaelSchoenburg/Get-AzureUserLicensing

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Creation: 08.11.2024
    Last Edit: 08.11.2024
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region INITIALIZATION
<# 
    Libraries, Modules, ...
#>

#Requires -Modules Microsoft.Graph
$MaximumVariableCount = 8192 # Graph Module has more than 4096 variables
Import-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users

#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

# The following variables have to be set by your skript runner:
<# 
$AzAppId = 'Hier eintragen'
$AzTenantId = 'Hier eintragen'
$LocalCertThumb = 'Hier eintragen'
#>

#endregion DECLARATIONS
#region FUNCTIONS
<# 
    Declare Functions
#>

#endregion FUNCTIONS
#region EXECUTION
<# 
    Script entry point
#>

# Suppress output by assigning to null
$null = Connect-MgGraph -ClientID $AzAppId -TenantId $AzTenantId -CertificateThumbprint $LocalCertThumb -NoWelcome

$licenses = Get-MgSubscribedSku | 
    Select-Object Id, ConsumedUnits, SkuId, SkuPartNumber, 
    @{Name = 'Name'; Expression = {switch ($_.SkuPartNumber) {
        # https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference
        'VISIOCLIENT' { 'Visio' }
        'ENTERPRISEPACK' { 'Office 365 E3' }
        'FLOW_FREE' { 'Microsoft Power Automate Free' }
        'SPB' { 'Microsoft 365 Business Premium' }
        'O365_BUSINESS_ESSENTIALS' { 'Microsoft 365 Business Basic' }
        Default {'Unbekannte Lizenz'}
    }}}

$Properties = 'DisplayName', 'AssignedLicenses', 'DisplayName', 'Givenname', 'Surname', 'UserPrincipalName', 'OnPremisesSamAccountName'
$Object = Get-MgUser -All -Filter 'accountEnabled eq true' -Property $Properties | 
    Sort-Object -Property DisplayName | 
    Select-Object @{Name = 'Kunde'; Expression = {'DRKNDK'}}, 
        @{Name = 'CenterLÖSUNG'; Expression = {'CenterOFFICE'}}, 
        @{Name = 'Lizenzierung'; Expression = {foreach ($l in $_.AssignedLicenses) {
            $licenses.Where({$_.SkuId -eq $l.SkuId}).Name
        }}}, 
        DisplayName, Givenname, Surname, UserPrincipalName, OnPremisesSamAccountName

$null = Disconnect-MgGraph

$Json = $Object | ConvertTo-Json

# Output
Write-Output 'Grafische Aufbereitung zum Debuggen: http://json2table.com/'
Write-Output '$Json.ToString()'
Write-Output $Json.ToString()
Write-Output '"$($Json.ToString())"'
Write-Output "$($Json.ToString())"
Write-Output '$Json'
Write-Output $Json

#endregion EXECUTION
