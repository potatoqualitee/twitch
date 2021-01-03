function New-ConfigFile {
    [CmdletBinding()]
    param()
    process {

        ######### Create directories
        $dir = Split-Path -Path $script:configfile

        if (-not (Test-Path -Path $dir)) {
            New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue
        }

        ######### Set variables and write to file
        if ((Get-TvSystemTheme).Theme -eq "dark") {
            $color = "White"
        } else {
            $color = "Black"
        }

        Write-Verbose "Writing config to $script:configfile"
        [PSCustomObject]@{
            ConfigFile       = $script:configfile.Replace("\\","\")
            DefaultFont      = "Segoe UI"
            RaidIcon         = $null
            RaidImage        = $null
            RaidText         = "HAS RAIDED!"
            RaidSound        = "ms-winsoundevent:Notification.IM"
            BitsIcon         = $null
            BitsImage        = $null
            BitsTitle        = "MERCI BEAUCOUP"
            BitsText         = "THANK YOU FOR THE"
            BitsSound        = "ms-winsoundevent:Notification.Mail"
            BotsToIgnore     = $null
            ClientId         = $null
            Token            = $null
            BotClientId      = $null
            BotToken         = $null
            BotChannel       = $null
            BotOwner         = $null
            NotifyColor      = $color
            BotIconColor     = $color
            BotIcon          = $null
            DiscordWebhook   = $null
            SubscriberSound  = "ms-winsoundevent:Notification.Mail"
            FollowerSound    = "ms-winsoundevent:Notification.Mail"
            UserCommandFile  = $userfile
            AdminCommandFile = $adminfile
            NotifyType       = "none"
            BotKey           = "!"
        } | ConvertFrom-RestResponse | ConvertTo-Json | Set-Content -Path $script:configfile -Encoding Unicode
    }
}