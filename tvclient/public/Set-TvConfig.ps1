function Set-TvConfig {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Secret")]
        [string]$Token,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotToken,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotChannel,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BotOwner,
        [ValidateSet("Transparent", "AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine", "Azure", "Beige", "Bisque", "Black", "BlanchedAlmond", "Blue", "BlueViolet", "Brown", "BurlyWood", "CadetBlue", "Chartreuse", "Chocolate", "Coral", "CornflowerBlue", "Cornsilk", "Crimson", "Cyan", "DarkBlue", "DarkCyan", "DarkGoldenrod", "DarkGray", "DarkGreen", "DarkKhaki", "DarkMagenta", "DarkOliveGreen", "DarkOrange", "DarkOrchid", "DarkRed", "DarkSalmon", "DarkSeaGreen", "DarkSlateBlue", "DarkSlateGray", "DarkTurquoise", "DarkViolet", "DeepPink", "DeepSkyBlue", "DimGray", "DodgerBlue", "Firebrick", "FloralWhite", "ForestGreen", "Fuchsia", "Gainsboro", "GhostWhite", "Gold", "Goldenrod", "Gray", "Green", "GreenYellow", "Honeydew", "HotPink", "IndianRed", "Indigo", "Ivory", "Khaki", "Lavender", "LavenderBlush", "LawnGreen", "LemonChiffon", "LightBlue", "LightCoral", "LightCyan", "LightGoldenrodYellow", "LightGray", "LightGreen", "LightPink", "LightSalmon", "LightSeaGreen", "LightSkyBlue", "LightSlateGray", "LightSteelBlue", "LightYellow", "Lime", "LimeGreen", "Linen", "Magenta", "Maroon", "MediumAquamarine", "MediumBlue", "MediumOrchid", "MediumPurple", "MediumSeaGreen", "MediumSlateBlue", "MediumSpringGreen", "MediumTurquoise", "MediumVioletRed", "MidnightBlue", "MintCream", "MistyRose", "Moccasin", "NavajoWhite", "Navy", "OldLace", "Olive", "OliveDrab", "Orange", "OrangeRed", "Orchid", "PaleGoldenrod", "PaleGreen", "PaleTurquoise", "PaleVioletRed", "PapayaWhip", "PeachPuff", "Peru", "Pink", "Plum", "PowderBlue", "Purple", "Red", "RosyBrown", "RoyalBlue", "SaddleBrown", "Salmon", "SandyBrown", "SeaGreen", "SeaShell", "Sienna", "Silver", "SkyBlue", "SlateBlue", "SlateGray", "Snow", "SpringGreen", "SteelBlue", "Tan", "Teal", "Thistle", "Tomato", "Turquoise", "Violet", "Wheat", "White", "WhiteSmoke", "Yellow", "YellowGreen")]
        [string]$NotifyColor,
        [string]$DiscordToken,
        [switch]$Force
    )
    begin {
        # maybe someone deleted their config file. If so, recreate it for them.
        if (-not (Test-Path -Path $script:configfile)) {
            New-Item -ItemType Directory -Path (Split-Path -Path $script:configfile) -ErrorAction SilentlyContinue
            @{
                ConfigFile = $script:configfile
            } | ConvertTo-Json | Set-Content -Path $script:configfile
        }
    }
    process {
        $config = Get-Content -Path $script:configfile | ConvertFrom-Json | ConvertTo-HashTable

        $ignore = [System.Management.Automation.PSCmdlet]::CommonParameters

        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -ne "Force" -and $key -notin $ignore) {
                $value = $PSBoundParameters.$key
                $config[$key] = $value
            }
        }

        $config | ConvertTo-Json | Set-Content -Path $script:configfile
        Get-TvConfig -Force:$Force
    }
}