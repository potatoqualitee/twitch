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
        [int]$MaxResults = 10,
        [switch]$Next
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
                if ($Since -eq "StreamStart") {
                    $online = Get-TvStream
                    if (-not $online) {
                        $lastvod = Get-TvVideo -MaxResults 1 | Select-Object -ExpandProperty Created
                        if (-not $lastvod) {
                            Write-Warning -Message "Twitter doesn't offer a way to detect this info"
                        }
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