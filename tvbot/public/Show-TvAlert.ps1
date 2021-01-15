function Show-TvAlert {
    <#
    .SYNOPSIS
        Shows an awesome alert. This command is awesomest on Windows 10 with BurntToast installed

    .DESCRIPTION
        Shows an awesome alert. This command is awesomest on Windows 10 with BurntToast installed

        This command causes alerts to show, and can help you when designing message/follow/sub alerts

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .PARAMETER Type
        The type of alert, including "Bits", "Follow", "Raid", "SubGifted", "Sub", and "Message"

    .PARAMETER Message
        The body of the message

    .PARAMETER Title
        The title displayed on the toast popup

    .PARAMETER MiscNumber
        Helper number for bits and gifted subs

    .PARAMETER MiscString
        Helper message for bits and gifted subs

    .PARAMETER Emote
        The ID of an emote

    .EXAMPLE
        PS> Show-TvAlert -UserName luzkenin -Type SubGifted -MiscNumber 3 -MiscString everyone

        Shows an alert for a Tier 3 gifted sub from luzkenin to everyone

    .EXAMPLE
        PS> Show-TvAlert -Message "Welcome to the fake chat" -Type Message -UserName potatoqualitee

        Shows a chat message alert from potatoqualitee

    .EXAMPLE
        PS> Show-TvAlert -UserName corbob -Type Bits -MiscNumber 1000

        Shows a bits alert from corbob for 1000 bits

    .EXAMPLE
        PS> Show-TvAlert -UserName MrMarkWest -Type Follow

        Shows a follow alert from MrMarkWest

    .EXAMPLE
        PS> Show-TvAlert -UserName mrmagou -Type Sub -MiscNumber 1

        Shows an alert for a Tier 1 sub

#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$UserName,
        [parameter(Mandatory)]
        [ValidateSet("Bits","Follow","Raid","SubGifted","Sub","Message")]
        [string]$Type,
        [string]$Message,
        [string]$Title,
        [int]$MiscNumber,
        [string]$MiscString,
        [int]$Emote
    )
    begin {
        function Get-TransformedValue {
            param($Value)

            $Value = $Value.Replace("<<username>>",$UserName)

            switch ($Type) {
                "Bits" {
                    if ($MiscNumber -eq 1) {
                        $bitword = "BIT"
                    } else {
                        $bitword = "BITS"
                    }
                    $Value = $Value.Replace("<<bitcount>>", "$MiscNumber $bitword")
                }
                "Sub" {
                    $MiscNumber = "$MiscNumber".ToCharArray() | Select-Object -First 1
                    $Value = $Value.Replace("<<tier>>", $MiscNumber)
                }
                "SubGifted" {
                    $MiscNumber = "$MiscNumber".ToCharArray() | Select-Object -First 1
                    $Value = $Value.Replace("<<gifter>>", $UserName)
                    $Value = $Value.Replace("<<tier>>", $MiscNumber)
                    $Value = $Value.Replace("<<giftee>>", $MiscString)
                }
            }
            $Value
        }
    }
    process {
        Write-TvSystemMessage -Type Verbose -Message $Message
        # i can probably just get-tvconifg once instead
        if ($Message) {
            $key = Get-TvConfigValue -Name BotKey
            if ($Message.StartsWith($key)) {
                # dont show
                return
            }
        }
        if ($PSVersionTable.Platform -eq "Win32NT" -and $PSVersionTable.PSEdition -eq "Core") {
            Write-Warning "Notifications not supported on Windows PowerShell Core. Use 5.1 instead."
            return
        }
        if ($Type -eq "Message") {
            if (-not $PSBoundParameters.Message) {
                throw "You must specify -Message when the -Type is Message"
            }
        } else {
            $icon = Get-TvConfigValue -Name ($Type, "icon" -join "")
            $image = Get-TvConfigValue -Name ($Type, "image" -join "")
            if ($PSBoundParameters.Title) {
                $Title = $PSBoundParameters.Title
            } else {
                $Title = Get-TvConfigValue -Name ($Type, "title" -join "")
            }
            if (-not $Message) {
                $Message = Get-TvConfigValue -Name ($Type, "text" -join "")
            }
        }

        if (-not $Title) {
            $Title = $UserName
        }
        $Title = Get-TransformedValue -Value $Title

        $Message = Get-TransformedValue -Value $message

        if (-not $image) {
            $image = Resolve-XPlatPath "$script:ModuleRoot\icon.png"
        }

        if (-not $script:toast) {
            $string = [System.Security.SecurityElement]::Escape($Message)
            try {
                Send-OSNotification -Title $Title -Body $string -Icon $image -ErrorAction Stop
            } catch {
                Write-TvSystemMessage -Type Verbose -Message "Failure $_"
            }
        } else {
            # Emotes can only be loaded by BurntToast
            if ($Emote) {
                $image = Get-TvEmote -Id $emote
            }

            if ($Type -eq "Message") {
                $image = Get-Avatar -UserName $UserName

                # let the chat go as fast as it needs.
                # if there's a notification being shown, remove it and make room
                if (Get-BTHistory -UniqueIdentifier tvbot) {
                    Remove-BTNotification -Tag tvbot -Group tvbot
                }
                if ($Emote) {
                    $theme = (Get-TvSystemTheme).Theme
                    $image = (Get-TvEmote -Id $emote).$theme
                }
                try {
                    # archive the chat to action center, this won't disappear even
                    # if the chat is going quickly
                    $uid = "archivechat$(Get-Date -Format FileDateTime)"
                    New-BurntToastNotification -AppLogo $image -Text $username, $message -UniqueIdentifier $uid -ErrorAction Stop -SuppressPopup
                    New-BurntToastNotification -AppLogo $image -Text $username, $message -UniqueIdentifier tvbot -ErrorAction Stop -ExpirationTime (Get-Date).AddSeconds(5)
                } catch {
                    Write-TvSystemMessage -Type Verbose -Message "Failure $_"
                }
            } else {
                if ($Type -in "Sub","Follow") {
                    $icon = Get-Avatar -UserName $UserName
                }
                $bticon = New-BTImage -Source $icon -AppLogoOverride
                $btimage = New-BTImage -Source $image -HeroImage
                $bttitle = New-BTText -Text $Title
                $bttext = New-BTText -Text $Message

                $sound = Get-TvConfigValue -Name ($Type, "sound" -join "")
                $soundenabled = Get-TvConfigValue -Name Sound
                if ($sound -and $soundenabled -eq "Enabled") {
                    $audio = New-BTAudio -Source $sound
                }

                Write-TvSystemMessage -Type Verbose -Message "Username: $UserName"
                Write-TvSystemMessage -Type Verbose -Message "Icon: $icon"
                Write-TvSystemMessage -Type Verbose -Message "Image: $image"
                Write-TvSystemMessage -Type Verbose -Message "Title: $Title"
                Write-TvSystemMessage -Type Verbose -Message "Message: $Message"
                Write-TvSystemMessage -Type Verbose -Message "Sound: $sound"

                $binding = New-BTBinding -Children $bttitle, $bttext -HeroImage $btimage -AppLogoOverride $bticon

                $visual = New-BTVisual -BindingGeneric $binding

                if ($audio) {
                    $content = New-BTContent -Visual $visual -Audio $audio
                } else {
                    $content = New-BTContent -Visual $visual
                }

                if (Get-BTHistory -UniqueIdentifier tvbot) {
                    Remove-BTNotification -Tag tvbot -Group tvbot
                }

                try {
                    $uid = "tvparty$(Get-Date -Format FileDateTime)"
                    Submit-BTNotification -Content $content -UniqueIdentifier $uid -ErrorAction Stop
                    if ($Type -ne $Message) {
                        # Don't allow chats to disrupt notifications
                        # Let the notification run for at least 5 seconds
                        Start-Sleep 5
                    }
                } catch {
                    Write-TvSystemMessage -Type Verbose -Message "Failure $_"
                }
            }
        }
    }
}