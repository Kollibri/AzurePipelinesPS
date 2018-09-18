﻿Function Set-ModuleData
{
    <#
    .SYNOPSIS

    Generate module data used to set static values for certian parameters.

    .DESCRIPTION

    Generate module data used to set static values for certian parameters.
    The sensetive data is encrypted and stored in the users local application data.

    .PARAMETER Instance
    
    The Team Services account or TFS server
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate, https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath    
    
    .INPUTS

    None. You cannot pipe objects to Set-ModuleData.

    .OUTPUTS

    None. Set-ModuleData returns nothing.

    .EXAMPLE

    C:\PS> Set-ModuleData -Instance 'https://myproject.visualstudio.com'

    .EXAMPLE

    C:\PS> Set-ModuleData -Collection 'DefaultCollection'

    .EXAMPLE

    C:\PS> Set-ModuleData -PersonalAccessToken 'myPatToken' 

    .LINK

    Get-ModuleData
    Remove-ModuleData
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Uri]
        $Instance,

        [Parameter()]
        [string]
        $Collection,

        [Parameter()]
        [string]
        $PersonalAccessToken,

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath        
    )
    Process
    {
        $export = $false
        If (-not($Script:ModuleDataPath))
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)] requires the global variable ModuleData that is populated during module import, please import the module." -ErrorAction Stop
        }
        If (-not(Test-Path $Path))
        {
            $null = New-Item -Path $Path -ItemType File -Force
            $null = Export-Clixml -Path $Path -InputObject @{}
        }
        $moduleData = Get-APModuleData -Path $Path
        If ($Instance)
        {
            If (-not($Instance.IsAbsoluteUri))
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$Instance] is not a valid uri" -ErrorAction Stop
            }
            $moduleData.Instance = $Instance.AbsoluteUri
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Instance has been set to [$($Instance.AbsoluteUri)]"
            $export = $true
        }        
        If ($PersonalAccessToken)
        {
            $securedPat = (ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force)
            $moduleData.PersonalAccessToken = $securedPat
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: PersonalAccessToken has been set"
            $export = $true
        }
        If ($Collection)
        {
            $moduleData.Collection = $Collection
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Collection has been set to [$Collection]"
            $export = $true
        }
        If ($export)
        {
            $moduleData | Export-Clixml -Path $Path  -Force
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Module data has been stored: [$PathPath]"
        }
    }
}
