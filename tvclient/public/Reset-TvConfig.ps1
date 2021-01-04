function Reset-TvConfig {
    <#
    .SYNOPSIS
        Gets configuration values

    .DESCRIPTION
        Gets configuration values

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    ()
    process {
        $dir = Split-Path -Path $script:configfile
        Get-ChildItem -Path $dir | Remove-Item -Force -ErrorAction SilentlyContinue
        New-ConfigFile

        # importing the module sets up pics and stuff too
        if (Get-Module -Name tvbot) {
            Import-Module tvbot -Force
        }

        Get-TvConfig
    }
}