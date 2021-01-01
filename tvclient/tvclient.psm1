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

switch ($PSVersionTable.Platform) {
    "Unix" { $script:configfile = "$home/tvclient/config.json" }
    default { $script:configfile = "$env:APPDATA\tvclient\config.json" }
}

if (-not (Test-Path -Path $script:configfile)) {
    New-Item -ItemType Directory -Path (Split-Path -Path $script:configfile) -ErrorAction SilentlyContinue
    @{
        Module = "tvclient"
    } | ConvertTo-Json | Set-Content -Path $script:configfile
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PSDefaultParameterValues["*:UseBasicParsing"] = $true

$script:pagination = @{}