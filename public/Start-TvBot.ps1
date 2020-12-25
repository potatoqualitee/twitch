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

    .PARAMETER Notify
        Sends toast notifications for all chats.

    .PARAMETER AutoReconnect
        Attempt to automatically reconnect if disconnected

    .EXAMPLE
        PS> Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs -Channel potatoqualitee

        Connects to irc.chat.twitch.tv on port 6697 as a bot with the Twitch account, mypsbot. potatoqualitee is the owner.

        Uses some default test commands. !ping and !pwd for users and !quit for admins.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$ClientId,
        [string]$Token,
        [Parameter(Mandatory)]
        [string[]]$Owner,
        [string]$Channel,
        [string]$Server = "irc.chat.twitch.tv",
        [int]$Port = 6697,
        [string]$Key = "!",
        [object]$UserCommand,
        [object]$AdminCommand,
        [ValidateSet("chat", "leave", "join")]
        [string[]]$Notify,
        [switch]$AutoReconnect
    )
    begin {
        $script:UserCommand = $UserCommand
        $script:AdminCommand = $AdminCommand
        $script:reconnect = $AutoReconnect
        if ($PSBoundParameters.Notify) {
            $script:mode = "notify"
        }
    }
    process {
        if (-not $PSBoundParameters.Channel) {
            if ($Owner.Count -eq 1) {
                $Channel = "$Owner"
            } else {
                throw "You must specify a Channel when assigning multiple owners"
            }
        }
        if ($PSBoundParameters.ClientId -and $PSBoundParameters.Token) {
            $null = Invoke-TvRequest -ClientId $ClientId -Token $Token

            if ($script:burnt) {
                $null = Start-Job -Name tvbot -ScriptBlock {
                    param (
                        [string]$ClientId,
                        [string]$Token
                    ) -AutoRemoveJob
                    Watch-TvViewCount -Client $ClientId -Token $Token } -ArgumentList $ClientId, $Token
            }
        }

        $params = @{
            Name   = $Name
            Token  = $Token
            Server = $Server
            Port   = $Port
            Owner  = $Owner
        }
        Connect-TvServer @params
        Join-TvChannel -Channel $Channel
        $params = @{
            UserCommand  = $script:UserCommand
            AdminCommand = $script:AdminCommand
            Channel      = $Channel
            Key          = $Key
        }
        if ($PSBoundParameters.Notify) {
            $params.Notify = $Notify
        }
        $script:startboundparams = $PSBoundParameters
        Wait-TvResponse @params
    }
}