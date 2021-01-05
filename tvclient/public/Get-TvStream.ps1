function Get-TvStream {
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