function Get-TvConfig {
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
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Name,
        [switch]$Force
    )
    begin {
        # maybe someone deleted their config file. If so, recreate it for them.
        if (-not (Test-Path -Path $script:configfile)) {
            $null = New-ConfigFile
        }
    }
    process {
        if ($PSBoundParameters.Name) {
            $results = Get-Content -Path $script:configfile | ConvertFrom-Json | Select-Object -Property $Name
        } else {
            $results = Get-Content -Path $script:configfile | ConvertFrom-Json
        }

        $columns = $results | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

        foreach ($value in $columns) {
            if ($results.$value) {
                $results.$value = $results.$value.ToString().Replace("\\","\")
            }
        }

        $arrays = "UsersToIgnore", "NotifyType", "BotOwner"
        foreach ($value in $arrays) {
            if ($results.$value) {
                $results.$value = $results.$value -split ", "
            }
        }

        # Order columns by column name
        $fields = $results | Get-Member -Type NoteProperty | Sort-Object Name | Select-Object -ExpandProperty Name

        # figure out how the command is being called
        # if called from the command line or from Set remove sensitive info
        $callstack = Get-PSCallStack

        if (($callstack).Count -eq 2 -or $callstack[1].Command -eq 'Set-TvConfig' -and -not $Force) {
            $hidden = "ClientID", "Token", "DiscordWebhook", "BotClientId", "BotToken"
            foreach ($item in $hidden) {
                if ($results.$item) {
                    $results.$item = "**************"
                }
            }
            $results | Select-Object -Property $fields
        } else {
            $results | Select-Object -Property $fields
        }
    }
}