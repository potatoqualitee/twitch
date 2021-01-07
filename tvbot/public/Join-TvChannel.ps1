
function Join-TvChannel {
    <#
    .SYNOPSIS
        Joins a channel.

    .DESCRIPTION
        Joins a channel.

    .PARAMETER Channel
        The name of the channel.

    .EXAMPLE
        PS> Join-TvChannel
    #>
    [CmdletBinding()]
    param ()
    if (-not $script:writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }

    $channels = Get-TvConfigValue -Name BotChannel

    foreach ($channel in $channels) {
        if ($channel -notmatch '\#') {
            $channel = "#$channel"
        }
        Send-Server -Message "JOIN $channel"
    }
}