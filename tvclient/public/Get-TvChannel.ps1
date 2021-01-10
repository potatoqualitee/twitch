function Get-TvChannel {
    <#
    .SYNOPSIS
        Gets channel information

    .DESCRIPTION
        Gets channel information

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        Description for MaxResults

    .PARAMETER Next
        Description for Next

    .EXAMPLE
        PS> Get-TvChannel

        Gets a list of channels

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
                Name       = "channel"
                Path       = "/channels?broadcaster_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            Invoke-Pagination @params
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "channel"
                    Path       = "/channels?broadcaster_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}