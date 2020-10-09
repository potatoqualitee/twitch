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

    if (-not $script:bot.Connection.GetStream()) {
        throw "*** Already disconnected 😊"
    }

    if ($Message) {
        Send-TvMessage -Message $Message -Channel $script:Channel
    }

    $writer.WriteLine("QUIT")
    $writer.Flush()
    $script:bot.Close()
    $script:channel = $script:line = $script:writer = $null
    $script:reader = $script:sslstream = $script:bot = $null
    $script:owner = $null
    Write-Output "*** Disconnected"
}