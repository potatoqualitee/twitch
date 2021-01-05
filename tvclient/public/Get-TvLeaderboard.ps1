function Get-TvLeaderboard {
    <#
    .SYNOPSIS
        Gets Twitch User
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