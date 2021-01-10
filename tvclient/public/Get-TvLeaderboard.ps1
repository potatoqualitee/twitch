function Get-TvLeaderboard {
    <#
    .SYNOPSIS
        Gets the leaderboard list

    .DESCRIPTION
        Gets the leaderboard list

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Period
        A period of time. Defaults to "all". Other options include day, week, month, and year.

    .EXAMPLE
        PS> Get-TvLeaderboard

        Gets a top 50 leaderboard list

    .EXAMPLE
        PS> Get-TvLeaderboard -MaxResults 100 -Period year

        Gets a top 100 leaderboard list for the past year

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,100)]
        [int]$MaxResults = 50,
        [ValidateSet("day","week", "month", "year", "all")]
        [string]$Period = "all"
    )
    process {
        Invoke-TvRequest -Path "/bits/leaderboard?count=$MaxResults&period=$Period"
    }
}