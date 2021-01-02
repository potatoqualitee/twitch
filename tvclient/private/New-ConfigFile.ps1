function New-ConfigFile {
    [CmdletBinding()]
    param()
    process {
        $dir = Split-Path -Path $script:configfile
        New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue

        if (-not (Test-Path -Path "$dir\pog.png")) {
            Copy-Item "$script:ModuleRoot\images\pog.png" -Destination "$dir\pog.png"
        }

        if (-not (Test-Path -Path "$dir\bits.gif")) {
            Copy-Item "$script:ModuleRoot\images\bits.gif" -Destination "$dir\bits.gif"
        }

        if (-not (Test-Path -Path "$dir\catparty.gif")) {
            Copy-Item "$script:ModuleRoot\images\catparty.gif" -Destination "$dir\catparty.gif"
        }

        if (-not (Test-Path -Path "$dir\vibecat.gif")) {
            Copy-Item "$script:ModuleRoot\images\vibecat.gif" -Destination "$dir\vibecat.gif"
        }

        if ((Get-TvSystemTheme).Theme -eq "dark") {
            $color = "White"
        } else {
            $color = "Black"
        }
        @{
            ConfigFile         = $script:configfile
            DefaultFont        = "Segoe UI"
            RaidIcon           = "$dir\images\pog.png"
            RaidImage          = "$dir\images\catparty.gif"
            RaidText           = "HAS RAIDED!"
            RaidSound          = "ms-winsoundevent:Notification.IM"
            BitsIcon           = "$dir\images\bits.gif"
            BitsImage          = "$dir\images\vibecat.gif"
            BitsTitle          = "MERCI BEAUCOUP"
            BitsText           = "THANK YOU FOR THE"
            BitsSound          = "ms-winsoundevent:Notification.Mail"
            BotsToIgnore       = $null
            ClientId           = $null
            Token              = $null
            BotClientId        = $null
            BotToken           = $null
            BotChannel         = $null
            BotOwner           = $null
            NotifyColor        = $color
            DiscordWebhook     = $null
            NewSubscriberSound = "ms-winsoundevent:Notification.Mail"
            NewFollowerSound   = "ms-winsoundevent:Notification.Mail"

        } | ConvertTo-Json | Set-Content -Path $script:configfile
    }
}