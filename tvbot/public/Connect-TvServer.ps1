function Connect-TvServer {
    <#
    .SYNOPSIS
        Connects the bot and establishes a session for a Twitch IRC server.

    .DESCRIPTION
       Connects the bot and establishes a session for a Twitch IRC server.

    .PARAMETER Name
        The IRC nickname of the bot

    .PARAMETER Token
        The plain-text Twitch token from https://twitchapps.com/tmi/

        SecureStrings were attempted but were not cross-platform yet :(

    .PARAMETER Server
        The Twitch IRC server. Defaults to irc.chat.twitch.tv.

    .PARAMETER Port
        The Twitch IRC Port. Defaults to 6697.

    .PARAMETER Owner
        The Twitch account or accounts that are owners of the bot

    .EXAMPLE
        PS> Connect-TvServer -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs

        Connects to irc.chat.twitch.tv on port 6697 as a bot with the Twitch account, mypsbot. potatoqualitee is the owner.
    #>
    [CmdletBinding()]
    Param (
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697
    )
    process {
        # automatically set variables
        $config = Get-TvConfig
        foreach ($name in ($config | Get-Member -MemberType NoteProperty).Name) {
            $null = Set-Variable -Name $name -Value $config.$name -Scope Local
        }

        if (-not $botclientid -and -not $bottoken) {
            Write-Error -ErrorAction Stop -Message "BotClientId and BotToken not set. Please use Set-TvConfig to proceed."
        }

        $botname = (Invoke-TvRequest -ClientId $botclientid -Token $bottoken -Path /users).Login

        if (-not $botchannel) {
            $null = Set-TvConfig -BotChannel $botname
        }

        try {
            $script:bot = New-Object System.Net.Sockets.TcpClient
            $bot.NoDelay = $true
            $bot.SendBufferSize = 81920
            $bot.ReceiveBufferSize = 81920

            Write-Output "> Connecting to $($Server):$Port"
            $bot.Connect($Server, $Port)
            $stream = $bot.GetStream()

            Write-Output "> Connected"
            $script:sslstream = New-Object System.Net.Security.SslStream $stream, $false
            $sslstream.AuthenticateAsClient($Server)

            $script:writer = New-Object System.IO.StreamWriter $sslstream
            $writer.NewLine = "`r`n"
            $script:reader = New-Object System.IO.StreamReader $sslstream

            # allow user to pass in a token starting or not starting with oauth:
            $auth = "PASS oauth:$($bottoken.Replace('oauth:', ''))"
            $nick = "NICK $botname"

            # enble extra features from twitch
            $capabilities = "CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands"

            Send-Server -Message $auth, $nick, $capabilities
        } catch {
            Write-Error -ErrorAction Stop -Message $_
        }
    }
}