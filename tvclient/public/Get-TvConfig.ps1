function Get-TvConfig {
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
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Name
    )
    process {
        if ($PSBoundParameters.Name) {
            Get-Content -Path $script:configfile | ConvertFrom-Json | Select-Object -Property $Name
        } else {
            Get-Content -Path $script:configfile | ConvertFrom-Json
        }
    }
}