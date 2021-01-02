function Get-TvSystemTheme {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

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