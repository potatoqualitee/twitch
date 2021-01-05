function Get-TvSubscriber {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [switch]$Next,
        [ValidateRange(1,100)]
        [int]$MaxResults = 50
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