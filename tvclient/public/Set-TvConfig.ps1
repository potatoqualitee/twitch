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
        # do this to avoid a huge list of colors AND ALSO
        # to ensure that the autocomplete works as expected
        # with partial matches
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                Get-ValidColor | Where-Object { $_ -like "$WordToComplete*" }
            }
        )]
        [string]$NotifyColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DefaultFont,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DiscordWebhook,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$NewSubcriberSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$NewFollowerSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$BotsToIgnore,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RaidIcon,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RaidImage,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RaidText,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RaidSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BitsIcon,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BitsImage,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BitsTitle,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$BitsSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Force
    )
    begin {
        # maybe someone deleted their config file. If so, recreate it for them.
        if (-not (Test-Path -Path $script:configfile)) {
            $null = New-ConfigFile
        }
    }
    process {
        if ($PSBoundParameters.NotifyColor -and $NotifyColor -notin (Get-ValidColor)) {
            Write-Warning -Message "$NotifyColor is not a valid color. You can tab through -NotifyColor to see a list. Resetting to Magenta"
            $PSBoundParameters.NotifyColor = "Magenta"
        }

        if ($PSBoundParameters.DefaultFont) {
            if ($DefaultFont -notin (New-Object System.Drawing.Text.InstalledFontCollection).Families) {
                Write-Warning -Message "The font $DefaultFont is not installed, using Segoe UI instead"
                $PSBoundParameters.DefaultFont = "Segoe UI"
            }
        }
        $config = Get-Content -Path $script:configfile | ConvertFrom-Json | ConvertTo-HashTable

        $ignore = [System.Management.Automation.PSCmdlet]::CommonParameters

        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -ne "Force" -and $key -notin $ignore) {
                if ($key -eq "BotsToIgnore") {
                    $value = $PSBoundParameters.$key -join ", "
                    $config[$key] = $value
                } else {
                    $value = $PSBoundParameters.$key
                    $config[$key] = $value
                }
            }
        }

        $config | ConvertTo-Json | Set-Content -Path $script:configfile
        Get-TvConfig -Force:$Force
    }
}