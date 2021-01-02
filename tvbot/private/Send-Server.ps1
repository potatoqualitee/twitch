function Send-Server {
    <#
        For communicating with the server
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Message,
        [string]$Channel,
        [string[]]$Owner = $script:Owner
    )

    if (-not $writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }

    foreach ($msg in $Message) {
        if ($msg -match "PASS ") {
            Write-Verbose "[$(Get-Date)] PASS ********"
        } else {
            Write-Verbose "[$(Get-Date)] $msg"
        }
        $writer.WriteLine($msg)
    }

    try {
        $writer.Flush()
    } catch {
        Write-Warning "Whoops! $_"
    }

    # Ping and pong do not return output it seems so no need to read the stream
    if ($reader.BaseStream.CanRead -and $Message -notin "PING", "PONG") {
        do {
            $script:line = $reader.ReadLine()
            if ($script:line) {
                if ($Channel) {
                    Write-TvOutput -InputObject $script:line -Channel $Channel
                } else {
                    Write-TvOutput -InputObject $script:line
                }
            }
        } while ($reader.Peek() -ne -1)
    }
}