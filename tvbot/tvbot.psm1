$script:ModuleRoot = $PSScriptRoot

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
foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
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
    $null = Set-TvConfig -AdminCommandFile $adminfile
}

if (-not (Get-TvConfigValue -Name AdminCommandFile)) {
    $null = Set-TvConfig -AdminCommandFile $userfile
}

######### Create user command files
if (-not (Test-Path -Path $userfile)) {
    @{
        ping = 'Write-TvChannelMessage -Message "$user, pong"'
        pwd  = 'Write-TvChannelMessage -Message $(Get-Location)'
    } | ConvertTo-Json | Set-Content -Path $userfile -Encoding Unicode
}

if (-not (Get-TvConfigValue -Name UserCommandFile)) {
    $null = Set-TvConfig -UserCommandFile $userfile
}

if (-not (Get-TvConfig -Name BotIcon)) {
    $botico = Join-Path -Path $PSScriptRoot -ChildPath "bot.ico"
    $null = Set-TvConfig -BotIcon $botico
}


if (Get-Command -Name New-BurntToastNotification -Module BurntToast -ErrorAction SilentlyContinue) {
    # sqlite shared cache
    $script:toast = $true
    $script:cache = @{}
    # set max notifications to 20
    $maxps = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe' -Name MaxCollapsedGroupItemCount -ErrorAction SilentlyContinue | Select-Object -ExpandProperty MaxCollapsedGroupItemCount

    if ($maxps -ne 21) {
        $null = Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe' -Name MaxCollapsedGroupItemCount -Value 21 -ErrorAction SilentlyContinue
    }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSVersionTable.Platform -ne "UNIX") {
    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
}

##################### Config setup #####################
$config = Get-TvConfig
$dir = Split-Path -Path $config.ConfigFile
$params = @{}

$pics = "robo.png", "vibecat.gif", "bits.gif", "catparty.gif", "pog.png", "pog-hero.png"
foreach ($pic in $pics) {
    if (-not (Test-Path -Path "$dir\$pic")) {
        Copy-Item "$script:ModuleRoot\images\$pic" -Destination "$dir\$pic"
    }
}

$settings = "RaidIcon", "SubIcon", "SubGiftedIcon"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = "$dir\pog.png"
    }
}

$settings = "RaidImage", "SubImage", "SubGiftedImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = "$dir\catparty.gif"
    }
}

if (-not $config.BitsIcon) {
    $params.BitsIcon = "$dir\bits.gif"
}


$settings = "BitsImage", "FollowImage"
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = "$dir\vibecat.gif"
    }
}

#placeholder
$settings = $null
foreach ($setting in $settings) {
    if (-not $config.$setting) {
        $params.$setting = "$dir\pog-hero.png"
    }
}

if (-not $config.BotIcon) {
    $params.BotIcon = "$dir\robo.png"
}

$null = Set-TvConfig @params