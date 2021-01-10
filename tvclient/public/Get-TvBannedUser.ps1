function Get-TvBannedUser {
    <#
    .SYNOPSIS
        Gets a list of banned users

    .DESCRIPTION
        Gets a list of banned users

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvBannedUser

        Gets a list of banned users

    .EXAMPLE
        PS> Get-TvBannedUser -MaxResults 100 -Next

        Gets the next batch of 100 banned users

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
            Name       = "bannedusers"
            Path       = "/moderation/banned?broadcaster_id=$script:userid"
            Next       = $Next
            MaxResults = $MaxResults
        }
        Invoke-Pagination @params
    }
}