function Set-TvConfig {
    <#
    .SYNOPSIS
        This is an essential command which helps set required configuration values

    .DESCRIPTION
        This is an essential command which helps set required configuration values for both tvclient and tvbot

        tvbot configs are initialized only when tvbot is installed and imported

    .PARAMETER ClientId
        Required client id for tvclient

        You can get this information from Twitch or twitchtokengenerator.com

    .PARAMETER Token
        Required token for tvclient

        You can get generate this token at twitchtokengenerator.com

    .PARAMETER BitsIcon
        Optional tvbot configuration for the bits alert icon used when BurntToast toast popups are enabled

    .PARAMETER BitsImage
        Optional tvbot configuration for the bits alert image

    .PARAMETER BitsSound
        Optional tvbot configuration for the bits alert sound

        To disable sounds, set Sound to Disabled

    .PARAMETER BitsText
        Optional tvbot configuration for the bits alert text

    .PARAMETER BitsTitle
        Optional tvbot configuration for the bits alert title

    .PARAMETER BotClientId
        Required tvbot client id. Create a bot account then get an API key from Twitch from twitchtokengenerator.com or twitchapps.com/tmi

    .PARAMETER BotChannel
        Optional tvbot channel. The bot joins its own channel by default, unless this value is set

    .PARAMETER BotIcon
        Optional tvbot configuration for the bot icon that appears in the taskbar when Windows 10 is used

    .PARAMETER BotIconColor
        Optional tvbot configuration for the color of the bot icon that appears in the taskbar when Windows 10 is used

    .PARAMETER BotKey
        The token that the bot responds to. So in "!say hello", ! would be the key. This value defaults to !

    .PARAMETER BotOwner
        The bot owner or owners that can execute admin commands

    .PARAMETER BotToken
        The required bot token. Create a bot account then get an API key from Twitch from twitchtokengenerator.com or twitchapps.com/tmi

    .PARAMETER UsersToIgnore
        The list of users to ignore so that their chat messages don't appear, such as Wizebot or Nightbot

    .PARAMETER DefaultFont
        Default font for Show-TvViewerCount. Defaults to Segoe UI

    .PARAMETER DiscordWebhook
        The Discord webhook to use with Send-TvDiscordMessage with tvbot

    .PARAMETER FollowIcon
        Optional tvbot configuration for the follow alert icon used when BurntToast toast popups are enabled

    .PARAMETER FollowImage
        Optional tvbot configuration for the follow alert image

    .PARAMETER FollowSound
        Optional tvbot configuration for the bits alert sound. To disable sounds, set Sound to Disabled

    .PARAMETER FollowText
        Optional tvbot configuration for the follow alert text

    .PARAMETER FollowTitle
        Optional tvbot configuration for the follow alert title

    .PARAMETER HueHub
        The IP or hostname of the Hue Hub used in the Start-TvHueParty tvbot command

        Visit http://sqlps.io/hue for more information on how to find the IP of your Philips Hue Hub

    .PARAMETER HueToken
        The Hue Token used in the Start-TvHueParty tvbot command

        Visit http://sqlps.io/hue for more information on how to generate a token for your Philips Hue Hub

    .PARAMETER NotifyColor
        Default color for Show-TvViewerCount notify icon

    .PARAMETER NotifyType
        Optional tvbot configuration for the type of notifications to show

        Options include none, chat, join, and follow

        Defaults to "none"

    .PARAMETER RaidIcon
        Optional tvbot configuration for the raid alert icon used when BurntToast toast popups are enabled

    .PARAMETER RaidImage
        Optional tvbot configuration for the raid alert image

    .PARAMETER RaidSound
        Optional tvbot configuration for the raid alert sound

        To disable sounds, set Sound to Disabled

    .PARAMETER RaidText
        Optional tvbot configuration for the raid alert text

    .PARAMETER RaidTitle
        Optional tvbot configuration for the raid alert title

    .PARAMETER Sound
        Optional tvbot configuration to enable or disable popup sounds

        Options include Enabled and Disabled

        Defaults to Enabled

    .PARAMETER SubGiftedText
        Optional tvbot configuration for the gifted sub alert text

    .PARAMETER SubGiftedTitle
        Optional tvbot configuration for the gifted sub alert title

    .PARAMETER SubGiftedIcon
        Optional tvbot configuration for the gifted sub alert icon

    .PARAMETER SubGiftedImage
        Optional tvbot configuration for the gifted sub alert iamge

    .PARAMETER SubGiftedSound
        Optional tvbot configuration for the gifted alert sound

        To disable sounds, set Sound to Disabled

    .PARAMETER SubIcon
        Optional tvbot configuration for the sub alert icon

    .PARAMETER SubImage
        Optional tvbot configuration for the sub alert image

    .PARAMETER SubSound
        Optional tvbot configuration for the sub alert sound

        To disable sounds, set Sound to Disabled

    .PARAMETER SubText
        Optional tvbot configuration for the sub alert text

    .PARAMETER SubTitle
        Optional tvbot configuration for the sub alert title

    .PARAMETER AdminCommandFile
        Optional tvbot configuration for the path to the AdminCommandFile, which is in JSON format

        It is recommended that you use Visual Studio Code to edit this file. You can also ignore this file and just use ScriptsToProcess

    .PARAMETER ScriptsToProcess
        Optional tvbot configuration for the path to the ScriptsToProcess

        These are scripts that are processed when tvbot receives both a username and message

        ScriptsToProcess are also run when a new sub and new follow are detected

    .PARAMETER UserCommandFile
        Optional tvbot configuration for the path to the UserCommandFile, which is in JSON format

        It is recommended that you use Visual Studio Code to edit this file. You can also ignore this file and just use ScriptsToProcess

    .PARAMETER Append
        For values that can append such as ScriptsToProcess, UsersToIgnore and NotifyType, append the new value to the current value

    .PARAMETER Force
        By default, sensitive values are obscured, use Force to show them unobscured

    .PARAMETER WhatIf
        Shows what would happen if the command would run

    .PARAMETER Confirm
        Displays (or disables using -Confirm:$false) a confirmation prompt

    .EXAMPLE
        PS> Set-TvConfig -ClientId abcxyz123 -Token 321zyxcba

        Sets the ClientId and Token used by all commands

    .EXAMPLE
        PS> Set-TvConfig -NotifyType chat

        Sets the notify type to "chat", which is used by the tvbot module

    .EXAMPLE
        PS> Set-TvConfig -BotChannel janedeaux

        Sets the tvbot channel to janedeaux. By default, the bot joins its own channel

    .EXAMPLE
        PS> Set-TvConfig -DiscordWebhook https://discord.com/api/webhooks/1234567890/ABC123XYZ

        Sets the webhook to be used by Send-TvDiscordMessage in the tvbot module

    .EXAMPLE
        PS> Set-TvConfig -NotifyColor Magenta

        Sets the notify color used by tvbot to Magenta

    .EXAMPLE
        PS> Set-TvConfig -HueHub hue.lab.local -HueToken abcdefh01234567ijklmop

        Sets the required information to be used by the tvbot command, Start-TvHueParty

#>
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [string]$BitsIcon,
        [string]$BitsImage,
        [string]$BitsSound,
        [string]$BitsText,
        [string]$BitsTitle,
        [string]$BotClientId,
        [string]$BotChannel,
        [string]$BotIcon,
        [string]$BotIconColor,
        [string]$BotKey,
        [string]$BotOwner,
        [string]$BotToken,
        [string[]]$UsersToIgnore,
        [string]$ClientId,
        [Alias("Secret")]
        [string]$Token,
        [string]$DefaultFont,
        [string]$DiscordWebhook,
        [string]$FollowIcon,
        [string]$FollowImage,
        [string]$FollowSound,
        [string]$FollowText,
        [string]$FollowTitle,
        [string]$HueHub,
        [string]$HueToken,
        # do this to avoid a huge list of colors AND ALSO
        # to ensure that the autocomplete works as expected
        # with partial matches
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                Get-ValidColor | Where-Object { $_ -like "$WordToComplete*" }
            }
        )]
        [string]$NotifyColor,
        [ValidateSet("chat", "leave", "join", "none")]
        [string[]]$NotifyType,
        [string]$RaidIcon,
        [string]$RaidImage,
        [string]$RaidSound,
        [string]$RaidText,
        [string]$RaidTitle,
        [parameter(DontShow)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$Sound,
        [string]$SubGiftedText,
        [string]$SubGiftedTitle,
        [string]$SubGiftedIcon,
        [string]$SubGiftedImage,
        [string]$SubGiftedSound,
        [string]$SubIcon,
        [string]$SubImage,
        [string]$SubSound,
        [string]$SubText,
        [string]$SubTitle,
        [string]$AdminCommandFile,
        [string[]]$ScriptsToProcess,
        [string]$UserCommandFile,
        [switch]$Append,
        [switch]$Force
    )
    begin {
        # maybe someone deleted their config file. If so, recreate it for them.
        if (-not (Test-Path -Path $script:configfile)) {
            $null = New-ConfigFile
        }
    }
    process {
        if ($PSBoundParameters.NotifyColor -and $NotifyColor -notin (Get-ValidColor)) {
            Write-Warning -Message "$NotifyColor is not a valid color. You can tab through -NotifyColor to see a list. Resetting to Magenta"
            $PSBoundParameters.NotifyColor = "Magenta"
        }

        if ($PSBoundParameters.DefaultFont -and -not $islinux) {
            if ($DefaultFont -notin (New-Object System.Drawing.Text.InstalledFontCollection).Families) {
                Write-Warning -Message "The font $DefaultFont is not installed, using Segoe UI instead"
                $PSBoundParameters.DefaultFont = "Segoe UI"
            }
        }
        $config = Get-Content -Path $script:configfile | ConvertFrom-Json | ConvertTo-HashTable

        $ignorecommonargs = [System.Management.Automation.PSCmdlet]::CommonParameters

        foreach ($key in $PSBoundParameters.Keys) {
            $hidden = "ClientID", "Token", "DiscordWebhook", "BotClientId", "BotToken"

            if ($key -notin $ignorecommonargs -and $key -notin "Append", "Force", "WhatIf", "Confirm") {
                if ($key -in "UsersToIgnore", "NotifyType", "BotOwner", "ScriptsToProcess") {
                    if ($Append) {
                        $value = @(Get-TvConfigValue -Name $key)
                        $value += $PSBoundParameters.$key
                        $value = $value -join ", "
                    } else {
                        $value = $PSBoundParameters.$key -join ", "
                    }
                    if ($PSCmdlet.ShouldProcess($script:configfile, "Set $key to $value")) {
                        $config[$key] = $value
                    }
                } else {
                    $value = $PSBoundParameters.$key
                    $config[$key] = $value

                    if ($key -in $hidden -and -not $Force) {
                        $value = "********************** (Use -Force to see)"
                    }
                    if ($PSCmdlet.ShouldProcess($script:configfile, "Set $key to $value")) {
                        # couldn't figure out how to do this lol
                    }
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($script:configfile, "Writing config file")) {
            $config | ConvertTo-Json | Set-Content -Path $script:configfile -Encoding Unicode
            Get-TvConfig -Force:$Force
        }
    }
}