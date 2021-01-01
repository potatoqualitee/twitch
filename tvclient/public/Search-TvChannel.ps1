function Search-TvChannel {
    <#
    .SYNOPSIS
        Gets Twitch User
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