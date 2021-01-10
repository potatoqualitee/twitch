function Search-TvChannel {
    <#
    .SYNOPSIS
        Searches a list of Twitch channels

    .DESCRIPTION
        Searches a list of Twitch channels

    .PARAMETER Query
        The keyword or keywords you'd like to search

    .EXAMPLE
        PS> Search-TvChannel -Query PowerShell

        Searches a list of twitch channels related to PowerShell
#>
    [CmdletBinding()]
    param
    (
        [string]$Query
    )
    process {
        $params = @{
            Name       = "channels"
            Path       = "/search/channels?query=$Query"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}