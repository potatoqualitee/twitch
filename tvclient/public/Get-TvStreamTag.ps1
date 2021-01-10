function Get-TvStreamTag {
    <#
    .SYNOPSIS
        Gets a list of stream tags

    .DESCRIPTION
        Gets a list of stream tags

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        The maximum number of results to return. The max value is 50 by default and can be no larger than 100.

    .PARAMETER Next
        The next set of results

    .EXAMPLE
        PS> Get-TvStreamTag

        Gets a list of stream tags

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
                Name       = "streamtag"
                Path       = "/streams/tags?broadcaster_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            Invoke-Pagination @params
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "streamtag"
                    Path       = "/streams/tags?broadcaster_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}