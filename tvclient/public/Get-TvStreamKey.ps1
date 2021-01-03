function Get-TvStreamKey {
    <#
    .SYNOPSIS
        Gets Twitch User
#>
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        $result = Invoke-TvRequest -Path "/streams/key?broadcaster_id=$script:userid"

        # if command is called from the command line, remove sensitive info
        $callstack = Get-PSCallStack
        if (($callstack).Count -eq 2 -and -not $Force) {
            $result.stream_key = "live_******************************"
        }
        [pscustomobject]@{
            StreamKey = $result.stream_key
        }
    }
}