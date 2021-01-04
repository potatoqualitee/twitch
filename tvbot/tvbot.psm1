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

######### Create user command files
if (-not (Test-Path -Path $userfile)) {
    @{
        ping = 'Write-TvChannelMessage -Message "$user, pong"'
        pwd  = 'Write-TvChannelMessage -Message $(Get-Location)'
    } | ConvertTo-Json | Set-Content -Path $userfile -Encoding Unicode
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
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSVersionTable.Platform -ne "UNIX") {
    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
}

##################### Config setup #####################
$config = Get-TvConfig
$dir = Split-Path -Path $config.ConfigFile
$params = @{}

if (-not $config.RaidIcon) {
    if (-not (Test-Path -Path "$dir\pog.png")) {
        Copy-Item "$script:ModuleRoot\images\pog.png" -Destination "$dir\pog.png"
    }
    $params.RaidIcon = "$dir\pog.png"
    $params.SubIcon = "$dir\pog.png"
}
if (-not $config.RaidImage) {
    if (-not (Test-Path -Path "$dir\catparty.gif")) {
        Copy-Item "$script:ModuleRoot\images\catparty.gif" -Destination "$dir\catparty.gif"
    }
    $params.RaidImage = "$dir\catparty.gif"
    $params.SubImage = "$dir\catparty.gif"
}
if (-not $config.BitsIcon) {
    if (-not (Test-Path -Path "$dir\bits.gif")) {
        Copy-Item "$script:ModuleRoot\images\bits.gif" -Destination "$dir\bits.gif"
    }
    $params.BitsIcon = "$dir\bits.gif"
}
if (-not $config.BitsImage) {
    if (-not (Test-Path -Path "$dir\vibecat.gif")) {
        Copy-Item "$script:ModuleRoot\images\vibecat.gif" -Destination "$dir\vibecat.gif"
    }
    $params.BitsImage = "$dir\vibecat.gif"
    $params.FollowImage = "$dir\vibecat.gif"
}

if (-not $config.BotIcon) {
    if (-not (Test-Path -Path "$dir\robo.png")) {
        Copy-Item "$script:ModuleRoot\images\robo.png" -Destination "$dir\robo.png"
    }
    $params.BotIcon = "$dir\robo.png"
}

if ($config.NotifyType -eq "none") {
    $params.NotifyType = "chat"
}
$null = Set-TvConfig @params