function Get-TvVideo {
    <#
    .SYNOPSIS
        Gets a list of videos

    .DESCRIPTION
        Gets a list of videos

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvVideo

        Gets a list of your VODs

    .EXAMPLE
        PS> Get-TvVideo -UserName potatoqualitee, CodeWithSean

        Gets a list of potatoqualitee's and CodeWithSean's VODs

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
            $params = @{
                Name       = "videos"
                Path       = "/videos?user_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            Invoke-Pagination @params
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "videos"
                    Path       = "/videos?user_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}