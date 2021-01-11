
function Join-TvChannel {
    <#
    .SYNOPSIS
        Joins a channel as defined by the BotChannel configuration value

    .DESCRIPTION
        Joins a channel as defined by the BotChannel configuration value

    .EXAMPLE
        PS> Join-TvChannel

        Joins the channel defined in BotChannel config
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