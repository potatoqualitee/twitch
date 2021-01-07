$script:ModuleRoot = $PSScriptRoot

# Import as fast as possible
function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )

    if ($doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

# Detect whether at some level dotsourcing was enforced
if ($tvbot_dotsourcemodule) { $script:doDotSource }

# Import all internal functions
foreach ($function in (Get-ChildItem -Path "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem -Path "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

######### Create directories
$dir = Split-Path -Path (Get-TvConfigValue -Name ConfigFile)

######### Create admin command files
$adminfile = Join-Path -Path $dir -ChildPath "admin-commands.json"
$userfile = Join-Path -Path $dir -ChildPath "user-commands.json"

if (-not (Test-Path -Path $adminfile)) {
    @{
        quit = 'Disconnect-TvServer -Message "k bye 👋!"'
    } | ConvertTo-Json | Set-Content -Path $adminfile -Encoding Unicode
}

if (-not (Get-TvConfigValue -Name AdminCommandFile)) {
    $null = Set-TvConfig -AdminCommandFile $adminfile
}

# set during load of tvbot
if ((Get-TvConfigValue -Name UserCommandFile)) {
    $null = Set-TvConfig -UserCommandFile $userfile
}

######### Create user command files
if (-not (Test-Path -Path $userfile)) {
    $say = '$message.Replace("!say ","")'
    @{
        ping      = 'Write-TvChannelMessage -Message "$user, pong"'
        pwd       = 'Write-TvChannelMessage -Message $(Get-Location)'
        psversion = 'Write-TvChannelMessage -Message ($PSVersionTable | Out-String)'
        hello     = 'Write-TvChannelMessage -Message "hi!"'
        say       = "Write-TvChannelMessage -Message $say"
    } | ConvertTo-Json | Set-Content -Path $userfile -Encoding Unicode
}

if (-not (Get-TvConfigValue -Name UserCommandFile)) {
    $null = Set-TvConfig -UserCommandFile $userfile
}

if (Get-Command -Name New-BurntToastNotification -Module BurntToast -ErrorAction SilentlyContinue) {
    # if they have BurntToast installed, it's assumed they are running windows 10
    $script:toast = $true
    $script:cache = @{}
}

if ($PSVersionTable.PSEdition -ne "Core") {
    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
}

##################### Config setup #####################
$config = Get-TvConfig
$dir = Split-Path -Path $config.ConfigFile
$params = @{}


$pics = "robo.png", "vibecat.gif", "bits.gif", "catparty.gif", "yay.gif",  "bot.ico"
foreach ($pic in $pics) {
    if (-not (Test-Path -Path "$dir\$pic")) {
        Copy-Item -Path "$script:ModuleRoot\images\$pic" -Destination "$dir\$pic"
    }
}

$settings = "BotIcon"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\bot.ico")
    }
}

$settings = "RaidIcon", "SubIcon", "SubGiftedIcon"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\yay.gif")
    }
}

$settings = "RaidImage", "SubImage", "SubGiftedImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\catparty.gif")
    }
}

if (-not $config.BitsIcon) {
    $params.BitsIcon = (Resolve-XPlatPath -Path "$dir\bits.gif")
}


$settings = "BitsImage", "FollowImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = (Resolve-XPlatPath -Path "$dir\vibecat.gif")
    }
}

######### Set variables and write to file
if ((Get-TvSystemTheme).Theme -eq "dark") {
    $color = "White"
} else {
    $color = "Black"
}

$newparams = @{
    BitsSound        = "ms-winsoundevent:Notification.Mail"
    BitsText         = "Thanks so much for the <<bitcount>>, <<username>> 🤩"
    BitsTitle        = "<<username>> shared bits!"
    BotClientId      = $null # set to null to lets user know its available
    BotIconColor     = $color
    BotKey           = "!"
    BotOwner         = $null
    BotToken         = $null
    UsersToIgnore    = $null
    DefaultFont      = "Segoe UI"
    FollowIcon       = $null # gets icon from the net but can default to this
    FollowSound      = "ms-winsoundevent:Notification.Mail"
    FollowText       = "Thanks so much for the follow, <<username>>!"
    FollowTitle      = "New follower 🥳"
    NotifyColor      = $color
    NotifyType       = "none"
    RaidSound        = "ms-winsoundevent:Notification.IM"
    RaidText         = $null # disabled for now bc the raid info comes from twitch
    RaidTitle        = "IT'S A RAID!"
    Sound            = "Enabled"
    SubGiftedText    = "Thank you so very much for gifting a Tier <<tier>> sub, <<gifter>>!"
    SubGiftedTitle   = "<<gifter>> has gifted <<giftee>> a sub 🤯"
    SubGiftedSound   = "ms-winsoundevent:Notification.Mail"
    SubSound         = "ms-winsoundevent:Notification.Mail"
    SubText          = "Thank you so very much for the tier <<tier>> sub, <<username>> 🤗"
    SubTitle         = "AWESOME!!"
    ScriptsToProcess = $null
}

foreach ($key in $newparams.Keys) {
    if (-not $config.$key) {
        $params.$key = $newparams[$key]
    }
}

$config = Set-TvConfig @params -Force
if (-not $config.BotClientId -and -not $config.BotToken) {
    Write-Warning "BotClientId and BotToken not found. Please use Set-TvConfig to set your BotClientId and BotToken. If no BotChannel is set, the bot will join its own channel."
}