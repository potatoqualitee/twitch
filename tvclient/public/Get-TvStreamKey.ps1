function Get-TvStreamKey {
    <#
    .SYNOPSIS
        Gets Twitch User
#>
    [CmdletBinding()]
    param()
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }
    }
    process {
        $result = Invoke-TvRequest -Path "/streams/key?broadcaster_id=$script:userid"
        [pscustomobject]@{
            StreamKey = $result.stream_key
        }
    }
}