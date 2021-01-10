function Get-TvModeratorEvent {
    <#
    .SYNOPSIS
        Gets a list of moderator events

    .DESCRIPTION
        Gets a list of moderator events

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvModeratorEvent

        Gets a list of moderator events

#>
    [CmdletBinding()]
    param
    (
        [ValidateRange(1,100)]
        [int]$MaxResults = 50,
        [switch]$Next
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        $params = @{
            Name       = "moderatorevents"
            Path       = "/moderation/moderators/events?broadcaster_id=$script:userid"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}