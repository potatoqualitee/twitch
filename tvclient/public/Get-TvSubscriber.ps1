function Get-TvSubscriber {
    <#
    .SYNOPSIS
        Gets a list of subscribers

    .DESCRIPTION
        Gets a list of subscribers

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 100 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvSubscriber

        Gets a list of subscribers

#>
    [CmdletBinding()]
    param
    (
        [ValidateRange(1,100)]
        [int]$MaxResults = 100,
        [switch]$Next
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        $params = @{
            Name       = "subscriber"
            Path       = "/subscriptions?broadcaster_id=$script:userid"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}