function Get-TvConfigValue {
    <#
    .SYNOPSIS
        Gets the value for a specified configuration. This comand will not obscure sensitive information.

    .DESCRIPTION
        Gets the value for a specified configuration. This comand will not obscure sensitive information.

    .EXAMPLE
        PS C:\> Get-TvConfigValue -Name BotToken

        Gets the BotToken value

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    process {
        Get-TvConfig -Name $Name | Select-Object -ExpandProperty $Name
    }
}