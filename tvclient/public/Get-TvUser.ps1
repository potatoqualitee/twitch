function Get-TvUser {
    <#
    .SYNOPSIS
        Gets detailed information about a user

    .DESCRIPTION
        Gets detailed information about a user

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .EXAMPLE
        PS> Get-TvUser

        Gets detailed information about your own account

    .EXAMPLE
        PS> Get-TvUser -UserName potatoqualitee, MarvRobot

        Gets detailed information for potatoqualitee and MarvRobot

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$UserName
    )
    process {
        if (-not $PSBoundParameters.UserName) {
            Invoke-TvRequest -Path /users
        } else {
            $users = $UserName -join "&login="
            Invoke-TvRequest -Path /users?login=$users
        }
    }
}