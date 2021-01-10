function Start-TvBot {
    <#
    .SYNOPSIS
        Combo-command that gets the bot completely online and responding

    .DESCRIPTION
        Combo-command that gets the bot completely online and responding

    .PARAMETER Server
        The Twitch IRC server. Defaults to irc.chat.twitch.tv.

    .PARAMETER Port
        The Twitch IRC port

        Defaults to 6697

    .PARAMETER NoAutoReconnect
        Do not attempt to automatically reconnect if disconnected

    .EXAMPLE
        PS> $splat = @{
                BotClientId      = "abcdefh01234567ijklmop"
                BotToken         = "01234567fghijklmnopqrs"
                BotOwner         = "potatoqualitee", "luzkenin"
                ScriptsToProcess = "C:\bot\response.ps1"
            }

        PS> Set-TvConfig @splat
        PS> Start-TvBot

        Connects to irc.chat.twitch.tv on port 6697 with the given bot's client id and token

        potatoqualitee and luzkenin are set as the owners and owners can execute admin commands
        from AdminCommandFile

        Admins can !quit

        Users can execute commands listed in UserCommandFile, such as !ping and !say
    #>
    [CmdletBinding()]
    param (
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697,
        [switch]$NoAutoReconnect,
        [switch]$NoHide,
        [parameter(DontShow)]
        [int]$PrimaryPid
    )
    process {
        if ($PrimaryPid) {
            $script:primarypid = $PrimaryPid
        }

        # Check if running in Core or in Windows Terminal ($env:WT_SESSION)
        if (-not $PSBoundParameters.NoHide -and ($PSVersionTable.PSEdition -eq "Core" -or $env:WT_SESSION)) {
            Write-Verbose -Message "Bot cannot be hidden when using PowerShell Core. Setting -NoHide."
            $PSBoundParameters.NoHide = $true
        }
        $script:startboundparams = $PSBoundParameters

        # this could be done a lot better
        # but @script:startboundparams isnt working
        $array = @()
        foreach ($key in $PSBoundParameters.Keys) {
            $value = $PSBoundParameters[$key]
            if ($value -in $true, $false) {
                $array += "-$($key):`$$value"
            } else {
                $array += "-$($key):'$value'"
            }
        }
        $script:flatparams = $array -join " "
        if (-not $NoAutoReconnect) { $script:reconnect = $true }

        if (-not $PSBoundParameters.NoHide -and $PSVersionTable.PSEdition -ne "Core") {
            Start-AlertJob
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