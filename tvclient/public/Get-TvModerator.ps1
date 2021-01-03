function Get-TvModerator {
    <#
    .SYNOPSIS
        Gets Twitch User
#>
    [CmdletBinding()]
    param
    (
        [ValidateRange(1,100)]
        [int]$MaxResults = 10,
        [switch]$Next
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        $params = @{
            Name       = "moderators"
            Path       = "/moderation/moderators?broadcaster_id=$script:userid"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}