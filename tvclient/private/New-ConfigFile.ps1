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
            AdminCommandFile = $null # set during load of tvbot
            ConfigFile       = $script:configfile.Replace("\\","\")
            BitsIcon         = $null
            BitsImage        = $null
            BitsSound        = "ms-winsoundevent:Notification.Mail"
            BitsText         = "THANK YOU FOR THE <<bitcount>>, <<username>>!"
            BitsTitle        = "MERCI BEAUCOUP, <<username>>!"
            BotClientId      = $null
            BotChannel       = $null
            BotIcon          = $null
            BotIconColor     = $color
            BotKey           = "!"
            BotOwner         = $null
            BotToken         = $null
            UsersToIgnore    = $null
            ClientId         = $null
            Token            = $null
            DefaultFont      = "Segoe UI"
            DiscordWebhook   = $null
            FollowIcon       = $null
            FollowImage      = $null
            FollowSound      = "ms-winsoundevent:Notification.Mail"
            FollowText       = "THANKS SO MUCH!"
            FollowTitle      = "WHAT UP, <<username>> HAS FOLLOWED!"
            NotifyColor      = $color
            NotifyType       = "none"
            RaidIcon         = $null
            RaidImage        = $null
            RaidSound        = "ms-winsoundevent:Notification.IM"
            RaidText         = "<<username>> HAS RAIDED!"
            RaidTitle        = "IT'S A RAID!"
            Sound            = "Enabled"
            SubGiftedText    = "Thank you so very much for gifting a Tier <<tier>> sub, <<gifter>>!"
            SubGiftedTitle   = "<<gifter>> has gifted <<giftee>> a sub!"
            SubGiftedIcon    = $null
            SubGiftedImage   = $null
            SubGiftedSound   = "ms-winsoundevent:Notification.Mail"
            SubIcon          = $null
            SubImage         = $null
            SubSound         = "ms-winsoundevent:Notification.Mail"
            SubText          = "Thank you so very much for the tier <<tier>> sub, <<username>>!"
            SubTitle         = "AWESOME!!"
            ScriptsToProcess = $null
            UserCommandFile  = $null # set during load of tvbot
        } | ConvertFrom-RestResponse | ConvertTo-Json | Set-Content -Path $script:configfile -Encoding Unicode
    }
}