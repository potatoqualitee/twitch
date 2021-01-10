function Get-TvFollower {
    <#
    .SYNOPSIS
        Gets a list of followers

    .DESCRIPTION
        Gets a list of followers

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .PARAMETER Since
        Show follows since StreamStarted, LastStream or a specified datetime (Get-Date)

    .EXAMPLE
        PS> Get-TvFollower

        Gets a list of the first 50 followers

    .EXAMPLE
        PS> Get-TvFollower -MaxResults 100 -Next -UserName potatoqualitee

        Gets the next batch of 100 followers of potatoqualitee

    .EXAMPLE
        PS> Get-TvFollower -Since StreamStarted

        Get a list of users who started following since your stream started

    .EXAMPLE
        PS> Get-TvFollower -Since (Get-Date).AddDays(-5)

        Get a list of users who started following in the last 5 days
#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$UserName,
        [ValidateRange(1,100)]
        [int]$MaxResults = 50,
        [switch]$Next,
        [psobject]$Since
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        if (-not $PSBoundParameters.UserName) {
            $params = @{
                Name       = "follower"
                Path       = "/users/follows?to_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            if (-not $PSBoundParameters.Since) {
                Invoke-Pagination @params
            } else {
                # Get max
                if (-not $PSBoundParameters.MaxResults) {
                    $params.MaxResults = 100
                }

                switch ($Since) {
                    { $PSItem -match "StreamStart" } {
                        $started = (Get-TvStream).StartedAt
                        if (-not $started) {
                            Write-Warning -Message "Stream not started ¯\_(ツ)_/¯"
                            return
                        }
                        Invoke-Pagination @params | Where-Object FollowedAt -gt $started
                    }
                    "LastStream" {
                        $lastvod = (Get-TvVideo -MaxResults 1).CreatedAt

                        if (-not $lastvod) {
                            Write-Warning -Message "No VODs found :("
                            return
                        }

                        Invoke-Pagination @params | Where-Object FollowedAt -gt $lastvod
                    }
                    default {
                        if ($since -isnot [datetime]) {
                            Write-Warning -Message "$Since is not a a datetime (Get-Date) or StreamStart or LastStream"
                            return
                        }
                        Invoke-Pagination @params | Where-Object FollowedAt -gt $Since
                    }
                }
            }
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "follower"
                    Path       = "/users/follows?to_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}