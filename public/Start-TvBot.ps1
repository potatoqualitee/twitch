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
        <#

        $id = (Invoke-TvRequest -Path /users?login=$Channel).data.id

        $subs = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$id -Verbose).data
        $follows = (Invoke-TvRequest -Path /users/follows?to_id=$id).data
        #>
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
                try {
                    $id = (Invoke-TvRequest -Path /users?login=$Channel -ErrorAction Stop).data.id
                    $subs = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$id -ErrorAction Stop).data
                    $follows = (Invoke-TvRequest -Path /users/follows?to_id=$id -ErrorAction Stop).data
                } catch {
                    $failedcheck = $true
                    Write-Warning "Error from webserver: $PSItem. Subs and follows will not be shown."
                }

                if (-not (Get-Job -Name tvbotviewers -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                    $null = Start-Job -Name tvbotviewers -ScriptBlock {
                        param (
                            [string]$ClientId,
                            [string]$Token
                        )
                        Watch-TvViewCount -Client $ClientId -Token $Token
                    } -ArgumentList $ClientId, $Token
                }

                if (-not $failedcheck) {
                    if (-not (Get-Job -Name tvbotsubsfollows -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                        $null = Start-Job -Name tvbotsubsfollows -ScriptBlock {
                            param (
                                [string]$ClientId,
                                [string]$Token,
                                [int]$Id,
                                [psobject[]]$Subs,
                                [psobject[]]$Follows,
                                [string]$ModuleRoot
                            )
                            $null = Invoke-TvRequest -Client $ClientId -Token $Token

                            while ($true) {
                                Start-Sleep -Seconds 3

                                # Get updated lists of follows and subs
                                $subupdate = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$Id).data
                                $followerupdate = (Invoke-TvRequest -Path /users/follows?to_id=$Id).data

                                $newfollowers = $followerupdate | Where-Object from_name -notin $Follows.from_name
                                $newsubs = $subupdate | Where-Object user_name -notin $Subs.user_name

                                foreach ($follower in $newfollowers.from_name) {
                                    $avatar = Invoke-TvRequest -Path /users?login=$follower
                                    $appicon = New-BTImage -Source $avatar.data.profile_image_url -AppLogoOverride
                                    $heroimage = New-BTImage -Source "$ModuleRoot\images\catparty.gif" -HeroImage

                                    $titletext = New-BTText -Text "NEW FOLLOWER!"
                                    $thankstext = New-BTText -Text "THANK YOU FOR THE FOLLOW, $follower!!"

                                    $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                                    $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                                    $visual = New-BTVisual -BindingGeneric $binding
                                    $content = New-BTContent -Visual $visual -Audio $audio

                                    Submit-BTNotification -Content $content -UniqueIdentifier $id
                                    Write-Warning WAITING
                                    Start-Sleep 5
                                }

                                foreach ($sub in $newsubs) {
                                    $subscriber = $sub.user_name
                                    <#
                                        gifter_name      :
                                        is_gift          : False
                                        plan_name        : Channel Subscription (potatoqualitee)
                                        tier             : 1000
                                        user_id          : 210963797
                                        user_name        : owenkbcodes
                                    #>
                                    $avatar = Invoke-TvRequest -Path /users?login=$subscriber
                                    $appicon = New-BTImage -Source $avatar.data.profile_image_url -AppLogoOverride
                                    $heroimage = New-BTImage -Source "$ModuleRoot\images\catparty.gif" -HeroImage

                                    $titletext = New-BTText -Text "NEW SUB!"
                                    $thankstext = New-BTText -Text "THANK YOU FOR THE subscription, $subscriber!!"

                                    $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                                    $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                                    $visual = New-BTVisual -BindingGeneric $binding
                                    $content = New-BTContent -Visual $visual -Audio $audio

                                    Submit-BTNotification -Content $content -UniqueIdentifier $id
                                }

                                $Subs = $subupdate
                                $Follows = $followerupdate
                            }
                        } -ArgumentList $ClientId, $Token, $id, $subs, $follows, $script:ModuleRoot
                    }
                }
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