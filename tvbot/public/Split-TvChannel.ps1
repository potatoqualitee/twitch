
function Split-TvChannel {
    <#
    .SYNOPSIS
        Leaves a channel

    .DESCRIPTION
        Leaves a channel

    .PARAMETER Channel
        The channel to leave. If no channel is specified, the configuration value for BotChannel will be used

    .EXAMPLE
        PS> Split-TvChannel

        Leaves the channel configured in BotChannel

    .EXAMPLE
        PS> Split-TvChannel -Channel potatoqualitee

        Leaves the potatoqualitee channel
    #>
    [CmdletBinding()]
    Param (
        [string]$Channel = (Get-TvConfigValue -Name BotChannel)
    )
    process {
        if (-not $script:writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        foreach ($room in $Channel) {
            if ($room -notmatch '\#') {
                $room = "#$room"
            }
            Write-TvChannelMessage -Message "Leaving"
            Send-Server -Message "LEAVE $room"
        }
    }
}