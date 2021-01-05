function Get-TvFollower {
    <#
    .SYNOPSIS
        Gets Twitch User
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
                $params.MaxResults = 500
                switch ($Since) {
                    "StreamStart" {
                        $started = (Get-TvStream).StartedAt
                        if (-not $started) {
                            Write-Warning -Message "Stream not started ¯\_(ツ)_/¯"
                            return
                        }
                        Invoke-Pagination @params | Where-Object FollowedAt -lt $started
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