function Wait-TvResponse {
    <#
    .SYNOPSIS
        Waits for the IRC Server to send data.

    .DESCRIPTION
        Waits for the IRC Server to send data.

    .PARAMETER Channel
        Optional channel to listen in

    .PARAMETER Key
        The chracter for the bot to listen for. Exclamation point by default.

        !likethis
        >likethis
        ?likethis

    .PARAMETER UserCommand
        The commands that users can use. Input can be JSON, a filename with JSON or a hashtable.

    .PARAMETER AdminCommand
        The commands that admins can use. Input can be JSON, a filename with JSON or a hashtable.

    .EXAMPLE
        PS> $params = @{
            UserCommand  = "C:\temp\user-commands.json"
            AdminCommand = "C:\temp\admin-commands.json"
            Channel      = "mypsbot"
            Key          = ">"
        }

        Wait-TvResponse  @params
    #>
    [CmdletBinding()]
    param (
        [string]$Channel = $script:Channel,
        [string]$Key = "!",
        [object]$UserCommand = $script:UserCommand,
        [object]$AdminCommand = $script:AdminCommand,
        [ValidateSet("chat", "leave", "join")]
        [string[]]$Notify
    )
    begin {
        $script:UserCommand = $UserCommand
        $script:AdminCommand = $AdminCommand
    }
    process {
        if (-not $script:line) {
            continue
        }

        if (-not $writer.BaseStream) {
            throw "Have you connected to a server using Connect-TvServer?"
        }

        $script:running = $true
        $active = $false
        $lasttick = $script:ping = [DateTime]::Now

        $inactivedelay = 1000
        $interactivedelay = 100
        $timerinterval = 0

        Write-Verbose -Message "About to loop"

        while ($script:running) {
            if ($active) {
                Start-Sleep -Milliseconds $interactivedelay
            } else {
                Start-Sleep -Milliseconds $inactivedelay
            }

            $active = $false

            if ($script:running -and $timerinterval) {
                if ((New-TimeSpan $lasttick ([DateTime]::Now)).TotalMilliseconds -gt $timerinterval) {
                    Send-Server -Message "PING"
                    $lasttick = $script:ping = [DateTime]::Now
                }
            } else {
                $lasttick = [DateTime]::Now
            }

            if ($script:ping -lt (Get-Date).AddMinutes(-20)) {
                # Reconnect
                Wait-TvResponse @PSBoundParameters
            }
            while ($script:running -and ($script:bot.GetStream().DataAvailable -or $reader.Peek() -ne -1)) {
                try {
                    $script:line = $reader.ReadLine()
                    $active = $true
                    $params = @{
                        InputObject  = $script:line
                        Owner        = $script:Owner
                        UserCommand  = $script:UserCommand
                        AdminCommand = $script:AdminCommand
                        Channel      = $Channel
                        Key          = $Key
                    }
                    if ($PSBoundParameters.Notify) {
                        $params.Notify = $Notify
                    }
                    Invoke-TvCommand @params
                } catch {
                    if ($PSBoundParameters.Notify -and $script:startboundparams -and $script:reconnect) {
                        Start-TVBot @script:startboundparams
                    } else {
                        throw "Cannot read stream: $_"
                    }
                }
            }
        }
    }
}