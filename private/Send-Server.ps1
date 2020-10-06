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
        throw "Have you connected to a server using Connect-TvServer?"
    }

    foreach ($msg in $Message) {
        $writer.WriteLine($msg)
    }

    try {
        $writer.Flush()
    } catch {
        Write-Warning "Whoops! $_"
    }

    if ($reader.BaseStream.CanRead) {
        do {
            $script:line = $reader.ReadLine()
            if ($Channel) {
                Write-TvOutput -InputObject $script:line -Channel $Channel
            } else {
                Write-TvOutput -InputObject $script:line
            }
        } while ($reader.Peek() -ne -1)
    }
}