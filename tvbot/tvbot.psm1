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