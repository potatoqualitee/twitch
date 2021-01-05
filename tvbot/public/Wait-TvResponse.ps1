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
        # Wait 1 second
        Write-Verbose "[$(Get-Date)] Sleeping a moment to let the server catch up"
        Start-Sleep -Seconds 1
        # this is where it fails when it mysteriously fails. it used to be a continue.
        if (-not $script:line) {
            Write-Verbose "[$(Get-Date)] Weird, it didn't have any input. Let's try to get one"
            $script:line = $script:reader.ReadLine()
        }

        if (-not $writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        $script:running = $true
        $active = $false
        $lasttick = $script:ping = [DateTime]::Now


        Write-Verbose -Message "[$(Get-Date)] Waiting for input by starting wait loop"

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
                    if ($script:startboundparams -and $script:running) {
                        Write-Verbose "[$(Get-Date)] Something went wrong, reconnecting"
                        Start-TvBot @script:startboundparams
                    } else {
                        throw "Cannot read stream: $_"
                    }
                }
            }
        }
    }
}