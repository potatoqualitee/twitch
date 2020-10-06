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

    .PARAMETER SecureToken
        The Twitch token from https://twitchapps.com/tmi/ in SecureString format

    .PARAMETER Server
        The Twitch IRC server. Defaults to irc.chat.twitch.tv.

    .PARAMETER Port
        The Twitch IRC Port. Defaults to 6697.

    .PARAMETER Owner
        The Twitch account or accounts that are owners of the bot

    .EXAMPLE
        PS> Connect-TvServer -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs

        Connects to irc.chat.twitch.tv on port 6697 as a bot with the Twitch account, mypsbot. potatoqualitee is the owner.

    .EXAMPLE
        PS> Connect-TvServer -Name mypsbot -Owner potatoqualitee -SecureToken (Get-Credential doesntmatter).Password

        Passes in a SecureString for the token and is never exposed
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Token,
        [securestring]$SecureToken,
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697,
        [Parameter(Mandatory)]
        [string[]]$Owner
    )
    process {
        if (-not $PSBoundParameters.Token -and -not $PSBoundParameters.SecureToken) {
            throw "Please provide either Token or SecureToken"
        }
        if ($PSBoundParameters.Token) {
            $SecureToken = ConvertTo-SecureString -AsPlainText $Token -Force
        }

        $script:Owner = $Owner

        try {
            $script:conn = New-Object System.Net.Sockets.TcpClient
            $conn.NoDelay = $true
            $conn.SendBufferSize = 81920
            $conn.ReceiveBufferSize = 81920

            Write-Output "> Connecting to $($Server):$Port"
            $conn.Connect($Server, $Port)
            $stream = $conn.GetStream()

            Write-Output "> Connected"
            $script:sslstream = New-Object System.Net.Security.SslStream $stream, $false
            $sslstream.AuthenticateAsClient($Server)

            $script:writer = New-Object System.IO.StreamWriter $sslstream
            $writer.NewLine = "`r`n"
            $script:reader = New-Object System.IO.StreamReader $sslstream

            $string1 = "PASS oauth:$(([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureToken)))).Replace('oauth:', ''))"
            $string2 = "NICK $Name"
            $string3 = "CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands"

            Send-Server -Message $string1, $string2, $string3
        } catch {
            throw $_
        }
    }
}