<#
.SYNOPSIS
    Get-AzureUserLicensing

.DESCRIPTION
    Long description

.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does

.INPUTS
    Inputs (if any)

.OUTPUTS
    Output (if any)

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

#Requires -Version 7
#Requires -Modules Microsoft.Graph
Import-Module Microsoft.Graph.Authentication, Microsoft.Graph.Users

#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

# The following variables have to be set by your skript runner:
$AzAppId = $args[0]
$AzTenantId = $args[1]
$LocalCertThumb = $args[3]

#endregion DECLARATIONS
#region FUNCTIONS
<# 
    Declare Functions
#>

function Write-ConsoleLog {
    <#
    .SYNOPSIS
    Logs an event to the console.
    
    .DESCRIPTION
    Writes text to the console with the current date (US format) in front of it.
    
    .PARAMETER Text
    Event/text to be outputted to the console.
    
    .EXAMPLE
    Write-ConsoleLog -Text 'Subscript XYZ called.'
    
    Long form
    .EXAMPLE
    Log 'Subscript XYZ called.
    
    Short form
    #>
    [alias('Log')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]
        $Text
    )

    # Save current VerbosePreference
    $VerbosePreferenceBefore = $VerbosePreference

    # Enable verbose output
    $VerbosePreference = 'Continue'

    # Write verbose output
    Write-Verbose "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"

    # Restore current VerbosePreference
    $VerbosePreference = $VerbosePreferenceBefore
}

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

$Object | ConvertTo-Json # http://json2table.com/#

#endregion EXECUTION
