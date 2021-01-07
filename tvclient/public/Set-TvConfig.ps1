function Set-TvConfig {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

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