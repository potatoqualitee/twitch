function Get-TvSystemTheme {
    <#
    .SYNOPSIS
        Gets system theme (dark or light)

    .DESCRIPTION
        Gets system theme (dark or light)

    .EXAMPLE
        PS C:\> Get-TvSystemTheme

        Gets system theme (dark or light)

#>
    [CmdletBinding()]
    param ()
    process {
        if ($PSVersionTable.Platform -eq "UNIX") {
            [pscustomobject]@{
                Theme = "dark"
                Color = "black"
            }
        } else {
            $reg = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize

            if ($reg.SystemUsesLightTheme) {
                $theme = "light"
                $color = "white"
            } else {
                $theme = "dark"
                $color = "black"
            }

            if ($script:configfile) {
                if (Test-Path -Path $script:configfile) {
                    if ($configcolor = Get-TvConfigValue -Name NotifyColor -ErrorAction SilentlyContinue) {
                        $color = $configcolor
                    }
                }
            }

            [pscustomobject]@{
                Theme = $theme
                Color = $color
            }
        }
    }
}