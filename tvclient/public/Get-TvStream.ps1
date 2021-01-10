function Get-TvStream {
    <#
    .SYNOPSIS
        Gets detailed stream information

    .DESCRIPTION
        Gets detailed stream information

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvStream

        Gets a list of streams

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$UserName,
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
        if (-not $PSBoundParameters.UserName) {
            $user = Get-TvUser
            Invoke-TvRequest -Path "/streams?user_login=$($user.Login)"
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                Invoke-TvRequest -Path "/streams?user_login=$($user.Login)"
            }
        }
    }
}