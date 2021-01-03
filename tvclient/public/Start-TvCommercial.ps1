function Start-TvCommercial {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param(
        [int]$Length = 60
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }

        $body = @{
            broadcaster_id = $script:userid
            length         = $Length
        }
    }
    process {
        Invoke-TvRequest -Method POST -Path "/channels/commercial" -Body $body
    }
}