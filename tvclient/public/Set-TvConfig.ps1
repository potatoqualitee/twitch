function Set-TvConfig {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Secret")]
        [string]$Token,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotToken
    )
    process {
        $config = Get-Content -Path $script:configfile | ConvertFrom-Json | ConvertTo-HashTable

        foreach ($key in $PSBoundParameters.Keys) {
            $value = $PSBoundParameters.$key
            $config[$key] = $value
        }

        $config | ConvertTo-Json | Set-Content -Path $script:configfile
    }
}