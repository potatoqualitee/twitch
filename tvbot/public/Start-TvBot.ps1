function Start-TvBot {
    <#
    .SYNOPSIS
        Combo-command that gets the bot completely online and responding.

    .DESCRIPTION
        Combo-command that gets the bot completely online and responding.

    .PARAMETER Server
        The Twitch IRC server. Defaults to irc.chat.twitch.tv.

    .PARAMETER Port
        The Twitch IRC Port. Defaults to 6697.

    .PARAMETER AutoReconnect
        Attempt to automatically reconnect if disconnected

    .EXAMPLE
        PS> Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs -Channel potatoqualitee

        Connects to irc.chat.twitch.tv on port 6697 as a bot with the Twitch account, mypsbot. potatoqualitee is the owner.

        Uses some default test commands. !ping and !pwd for users and !quit for admins.
    #>
    [CmdletBinding()]
    param (
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697,
        [switch]$AutoReconnect,
        [switch]$NoTrayIcon,
        [parameter(DontShow)]
        [int]$PrimaryPid
    )
    process {
        if ($PrimaryPid) {
            $script:primarypid = $PrimaryPid
        }
        $script:startboundparams = $PSBoundParameters
        if ($AutoReconnect) { $script:reconnect = $true }

        if (-not $PSBoundParameters.NoTrayIcon -and $PSVersionTable.Platform -ne "UNIX") {
            Start-Bot
        } else {
            if ($PrimaryPid) {
                Set-ConsoleIcon
            }
            Connect-TvServer
            Join-TvChannel
            Wait-TvResponse
        }
    }
}