function Send-Server {
    <#
        For communicating with the server
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Message
    )

    if (-not $script:writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }

    foreach ($msg in $Message) {
        if ($msg -match "PASS ") {
            Write-Verbose "[$(Get-Date)] PASS ********"
        } else {
            Write-Verbose "[$(Get-Date)] $msg"
        }
        $script:writer.WriteLine($msg)
    }

    try {
        $script:writer.Flush()
    } catch {
        Write-Warning "Whoops! $_"
    }

    # Ping and pong do not return output it seems so no need to read the stream
    if ($script:reader.BaseStream.CanRead -and $Message -notin "PING", "PONG") {
        do {
            $script:line = $script:reader.ReadLine()
            if ($script:line) {
                Write-TvOutput -InputObject $script:line
            }
        } while ($script:reader.Peek() -ne -1)
    }
}