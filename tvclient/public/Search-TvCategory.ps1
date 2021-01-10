function Search-TvCategory {
    <#
    .SYNOPSIS
        Searches a list of Twitch categories

    .DESCRIPTION
        Searches a list of Twitch categories

    .PARAMETER Query
        The keyword or keywords you'd like to search

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .EXAMPLE
        PS> Search-TvCategory -Query PowerShell

        Searches a list of twitch categories related to PowerShell

#>
    [CmdletBinding()]
    param
    (
        [string]$Query,
        [int]$MaxResults = 50
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