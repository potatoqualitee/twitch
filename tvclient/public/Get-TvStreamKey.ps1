function Get-TvStreamKey {
    <#
    .SYNOPSIS
        Gets your stream key. By default, the output is obscured. Use -Force to show the key.

    .DESCRIPTION
        Gets your stream key. By default, the output is obscured. Use -Force to show the key.

    .PARAMETER Force
        Gets your stream key. By default, the output is obscured. Use -Force to show the key.

    .EXAMPLE
        PS> Get-TvStreamKey

        Gets an obscured streamkey

    .EXAMPLE
        PS> Get-TvStreamKey -Force

        Gets an unobscured streamkey

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