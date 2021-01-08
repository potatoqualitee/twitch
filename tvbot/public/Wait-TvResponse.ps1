function Wait-TvResponse {
    <#
    .SYNOPSIS
        Waits for the IRC Server to send data.

    .DESCRIPTION
        Waits for the IRC Server to send data.

    .EXAMPLE
        PS>
    #>
    [CmdletBinding()]
    param ()
    process {
        if (-not $script:writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        # Wait 1 second
        Write-TvVerbose -Message "Sleeping a moment to let the server catch up"
        Start-Sleep -Seconds 1
        # this is where it fails when it mysteriously fails. it used to be a continue.
        if (-not $script:line) {
            Write-Warning "[$(Get-Date)] Weird, it didn't have any input. Let's try to get one"
            try {
                try {
                    $script:line = $script:reader.ReadLine()
                } catch {
                    if ($script:reconnect) {
                        Write-Warning "[$(Get-Date)] Something went wrong. Problem: $PSItem"
                        Write-Warning "[$(Get-Date)] Trying to reconnect.."
                        $script:bot.Close()
                        $script:channel = $script:line = $script:writer = $null
                        $script:reader = $script:sslstream = $script:bot = $null
                        Start-TvBot @script:startboundparams
                    } else {
                        throw "Disconnecting due to $PSItem because NoAutoReconnect was specified"
                    }
                }
            } catch {
                throw "Can't connect: $PSItem"
            }
        }

        if (-not $script:writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        $script:running = $true
        $active = $false
        $lasttick = $script:ping = [DateTime]::Now


        Write-TvVerbose -Message "Waiting for input by starting wait loop"

        while ($script:running) {
            if ($active) {
                $interactivedelay = 100
                Start-Sleep -Milliseconds $interactivedelay
            } else {
                $inactivedelay = 1000
                Start-Sleep -Milliseconds $inactivedelay
            }

            $active = $false
            $timerinterval = 0
            if ($script:running -and $timerinterval) {
                if ((New-TimeSpan $lasttick ([DateTime]::Now)).TotalMilliseconds -gt $timerinterval) {
                    Send-Server -Message "PING"
                    $lasttick = $script:ping = [DateTime]::Now
                }
            } else {
                $lasttick = [DateTime]::Now
            }

            # Reconnect
            if ($script:ping -lt (Get-Date).AddMinutes(-20)) {
                Start-TvBot @script:startboundparams
            }

            while ($script:running -and ($script:bot.GetStream().DataAvailable -or $reader.Peek() -ne -1)) {
                try {
                    $script:line = $reader.ReadLine()
                    $active = $true
                    Invoke-TvCommand -InputObject $script:line
                } catch {
                    if ($script:startboundparams -and $script:running -and $script:reconnect) {
                        Write-Warning "[$(Get-Date)] Something went wrong. Problem: $PSItem"
                        Write-Warning "[$(Get-Date)] Trying to reconnect.."
                        $script:bot.Close()
                        $script:channel = $script:line = $script:writer = $null
                        $script:reader = $script:sslstream = $script:bot = $null
                        Start-TvBot @script:startboundparams
                    } else {
                        throw "Cannot read stream: $_"
                    }
                }
            }
        }
    }
}