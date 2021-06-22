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
foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

switch ($PSVersionTable.Platform) {
    "Unix" { $script:configfile = "$home/tvclient/config.json" }
    default { $script:configfile = "$env:APPDATA\tvclient\config.json" }
}

if (-not (Test-Path -Path $script:configfile)) {
    $null = New-ConfigFile
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PSDefaultParameterValues["*:UseBasicParsing"] = $true
$script:pagination = @{}

##################### Auto-complete setup #####################
Add-Type -AssemblyName System.Drawing
$script:knowncolors = [Enum]::GetValues([System.Drawing.KnownColor]) | Where-Object {
    $PSItem -notmatch "Active|Workspace|Button|Control|Desktop|Highlight|Border|Caption|Menu|Scroll|Window"
}

$script:sounds = 'ms-winsoundevent:Notification.Default',
'ms-winsoundevent:Notification.IM',
'ms-winsoundevent:Notification.Mail',
'ms-winsoundevent:Notification.Reminder',
'ms-winsoundevent:Notification.SMS',
'ms-winsoundevent:Notification.Looping.Alarm',
'ms-winsoundevent:Notification.Looping.Alarm2',
'ms-winsoundevent:Notification.Looping.Alarm3',
'ms-winsoundevent:Notification.Looping.Alarm4',
'ms-winsoundevent:Notification.Looping.Alarm5',
'ms-winsoundevent:Notification.Looping.Alarm6',
'ms-winsoundevent:Notification.Looping.Alarm7',
'ms-winsoundevent:Notification.Looping.Alarm8',
'ms-winsoundevent:Notification.Looping.Alarm9',
'ms-winsoundevent:Notification.Looping.Alarm10',
'ms-winsoundevent:Notification.Looping.Call',
'ms-winsoundevent:Notification.Looping.Call2',
'ms-winsoundevent:Notification.Looping.Call3',
'ms-winsoundevent:Notification.Looping.Call4',
'ms-winsoundevent:Notification.Looping.Call5',
'ms-winsoundevent:Notification.Looping.Call6',
'ms-winsoundevent:Notification.Looping.Call7',
'ms-winsoundevent:Notification.Looping.Call8',
'ms-winsoundevent:Notification.Looping.Call9',
'ms-winsoundevent:Notification.Looping.Call10'

Register-ArgumentCompleter -ParameterName SubSound -CommandName Set-TvConfig -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $script:sounds | Where-Object { $PSitem -match $wordToComplete } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}

Register-ArgumentCompleter -ParameterName FollowSound -CommandName Set-TvConfig -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $script:sounds | Where-Object { $PSitem -match $wordToComplete } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}

Register-ArgumentCompleter -ParameterName Since -CommandName Get-TvFollower -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $querytool.values | Select-Object -Unique | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}

Register-ArgumentCompleter -ParameterName Name -CommandName Get-TvConfig -ScriptBlock {
    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
    (Get-Command -Name Set-TvConfig).Parameters.Keys | Where-Object {
        $PSItem -notin "Append", "Force", "WhatIf", "Confirm"
        -and $PSItem -notin [System.Management.Automation.PSCmdlet]::CommonParameters
        -and $PSItem -like "$WordToComplete*"
    } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($PSItem, $PSItem, "ParameterName", $PSItem)
    }
}

$config = Get-TvConfig
if (-not $config.ClientId -and -not $config.Token) {
    Write-Warning "ClientId and Token not found. Please use Set-TvConfig to set your ClientId and Token."
}