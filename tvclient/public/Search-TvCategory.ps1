function Search-TvCategory {
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
            Name       = "categories"
            Path       = "/search/categories?query=$Query"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}