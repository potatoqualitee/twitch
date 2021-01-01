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
        [string]$DiscordToken,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$NewSubcriberSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$NewFollowerSound,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Force
    )
    begin {
        # maybe someone deleted their config file. If so, recreate it for them.
        if (-not (Test-Path -Path $script:configfile)) {
            New-Item -ItemType Directory -Path (Split-Path -Path $script:configfile) -ErrorAction SilentlyContinue
            @{
                ConfigFile  = $script:configfile
                DefaultFont = "Segoe UI"
            } | ConvertTo-Json | Set-Content -Path $script:configfile
        }
    }
    process {
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
                $value = $PSBoundParameters.$key
                $config[$key] = $value
            }
        }

        $config | ConvertTo-Json | Set-Content -Path $script:configfile
        Get-TvConfig -Force:$Force
    }
}