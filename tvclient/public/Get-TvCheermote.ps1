function Get-TvCheermote {
    <#
    .SYNOPSIS
        Gets a list of cheermotes

    .DESCRIPTION
        Gets a list of cheermotes

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        Description for MaxResults

    .PARAMETER Next
        Description for Next

    .EXAMPLE
        PS> Get-TvCheermote

        Gets a list of cheermotes

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
                Name       = "cheermotes"
                Path       = "/bits/cheermotes?broadcaster_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            Invoke-Pagination @params
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "cheermotes"
                    Path       = "/bits/cheermotes?broadcaster_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}