function Set-TvConfig {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
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
        [string[]]$BotsToIgnore,
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
        [ValidateSet("Enabled", "Disabled")]
        [string]$Sound,
        [string]$SubIcon,
        [string]$SubImage,
        [string]$SubSound,
        [string]$SubText,
        [string]$SubTitle,
        [string]$AdminCommandFile,
        [string]$UserCommandFile,
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

        if ($PSBoundParameters.DefaultFont) {
            if ($DefaultFont -notin (New-Object System.Drawing.Text.InstalledFontCollection).Families) {
                Write-Warning -Message "The font $DefaultFont is not installed, using Segoe UI instead"
                $PSBoundParameters.DefaultFont = "Segoe UI"
            }
        }
        $config = Get-Content -Path $script:configfile | ConvertFrom-Json | ConvertTo-HashTable

        $ignore = [System.Management.Automation.PSCmdlet]::CommonParameters

        foreach ($key in $PSBoundParameters.Keys) {
            $hidden = "ClientID", "Token", "DiscordWebhook", "BotClientId", "BotToken"

            if ($key -ne "Force" -and $key -notin $ignore) {
                if ($key -in "BotsToIgnore", "NotifyType", "BotOwner") {
                    $value = $PSBoundParameters.$key -join ", "
                    $config[$key] = $value
                } else {
                    $value = $PSBoundParameters.$key
                    $config[$key] = $value

                    if ($key -in $hidden -and -not $Force) {
                        $value = "********************** (Use -Force to see)"
                    }
                }
                Write-Verbose -Message "Set $key to $value"
            }
        }

        $config | ConvertTo-Json | Set-Content -Path $script:configfile -Encoding Unicode
        Get-TvConfig -Force:$Force
    }
}