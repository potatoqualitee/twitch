function Start-TvBot {
    <#
    .SYNOPSIS
        Combo-command that gets the bot completely online and responding.

    .DESCRIPTION
        Combo-command that gets the bot completely online and responding.

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

    .PARAMETER Key
        The chracter for the bot to listen for. Exclamation point by default.

        !likethis
        >likethis
        ?likethis

    .PARAMETER UserCommand
        The commands that users can use. Input can be JSON, a filename with JSON or a hashtable.

    .PARAMETER AdminCommand
        The commands that admins can use. Input can be JSON, a filename with JSON or a hashtable.

    .EXAMPLE
        PS> Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs -Channel potatoqualitee

        Connects to irc.chat.twitch.tv on port 6697 as a bot with the Twitch account, mypsbot. potatoqualitee is the owner.

        Uses some default test commands. !ping and !pwd for users and !quit for admins.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Token,
        [securestring]$SecureToken,
        [Parameter(Mandatory)]
        [string[]]$Owner,
        [Parameter(Mandatory)]
        [string]$Channel,
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697,
        [string]$Key = "!",
        [object]$UserCommand,
        [object]$AdminCommand
    )
    begin {
        $script:UserCommand = $UserCommand
        $script:AdminCommand = $AdminCommand
    }
    process {
        $params = @{
            Name        = $Name
            Token       = $Token
            SecureToken = $SecureToken
            Server      = $Server
            Port        = $Port
            Owner       = $Owner
        }
        Connect-TvServer @params
        Join-TvChannel -Channel $Channel

        $params = @{
            UserCommand  = $script:UserCommand
            AdminCommand = $script:AdminCommand
            Channel      = $Channel
            Key          = $Key
        }

        Wait-TvResponse  @params
    }
}