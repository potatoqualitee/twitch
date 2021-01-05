function Send-Greet {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [switch]$Next,
        [ValidateRange(1,100)]
        [int]$MaxResults = 100
    )
    begin {
    }
    process {
    }
}