function Disconnect-TvServer {
    <#
    .SYNOPSIS
        Disconnect the bot from the server.

    .DESCRIPTION
        Disconnect the bot from the server.

    .PARAMETER Message
        Optional leaving message

    .EXAMPLE
        PS> Disconnect-TvServer -Message "Gotta go!"
    #>
    [CmdletBinding()]
    param (
        [string]$Message
    )

    if (-not $writer.BaseStream) {
        throw "*** Already disconnected 😊"
    }

    if ($Message) {
        Send-TvMessage -Message $Message -Channel $script:Channel
    }

    $writer.WriteLine("QUIT")
    $writer.Flush()
    $conn.Close()
    $script:channel = $script:line = $script:writer = $null
    $script:reader = $script:sslstream = $script:conn = $null
    $script:owner = $null
    Write-Output "*** Disconnected"
}