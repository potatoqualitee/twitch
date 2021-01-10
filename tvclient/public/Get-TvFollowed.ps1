function Get-TvFollowed {
    <#
    .SYNOPSIS
        Gets a list of everyone you or someone else has followed

    .DESCRIPTION
        Gets a list of everyone you or someone else has followed

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER MaxResults
        Description for MaxResults

    .PARAMETER Next
        Description for Next

    .EXAMPLE
        PS> Get-TvFollowed

        Gets a list of everyone you have followed

    .EXAMPLE
        PS> Get-TvFollowed -UserName potatoqualitee

        Gets a list of everyone potatoqualitee has followed
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
                Name       = "followed"
                Path       = "/users/follows?from_id=$script:userid"
                Next       = $Next
                MaxResults = $MaxResults
            }
            Invoke-Pagination @params
        } else {
            $users = Get-TvUser -UserName $UserName
            foreach ($user in $users) {
                $params = @{
                    Name       = "followed"
                    Path       = "/users/follows?from_id=$($user.id)"
                    Next       = $Next
                    MaxResults = $MaxResults
                }
                Invoke-Pagination @params
            }
        }
    }
}