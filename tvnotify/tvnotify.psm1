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

if (Get-Command -Name New-BurntToastNotification -Module BurntToast -ErrorAction SilentlyContinue) {
    # sqlite shared cache
    $script:toast = $true
    $script:cache = @{}
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSVersionTable.Platform -ne "UNIX") {
    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
}