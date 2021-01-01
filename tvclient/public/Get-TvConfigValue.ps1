function Get-TvConfigValue {
    <#
    .SYNOPSIS
        Gets configuration values

    .DESCRIPTION
        Gets configuration values

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    process {
        Get-Content -Path $script:configfile | ConvertFrom-Json | Select-Object -ExpandProperty $Name
    }
}