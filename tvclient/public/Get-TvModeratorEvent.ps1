function Get-TvModeratorEvent {
    <#
    .SYNOPSIS
        Gets Twitch User
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