function Reset-TvConfig {
    <#
    .SYNOPSIS
        Resets all of your tvbot and tvclient configs

    .DESCRIPTION
        Resets all of your tvbot and tvclient configs

    .EXAMPLE
        PS> Reset-TvConfig

        Resets all of your tvbot and tvclient configs

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