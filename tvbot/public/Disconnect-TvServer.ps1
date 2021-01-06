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

    if (-not $script:bot.GetStream()) {
        Write-Error -ErrorAction Stop -Message "*** Already disconnected 😊"
    }

    if ($Message) {
        Write-TvChannelMessage -Message $Message
    }

    $script:writer.WriteLine("QUIT")
    $script:writer.Flush()
    $script:running = $false
    $script:bot.Close()
    $script:channel = $script:line = $script:writer = $null
    $script:reader = $script:sslstream = $script:bot = $null
    Write-Output "*** Disconnected"

    if ($script:notifyicon) {
        $script:notifyicon.Visible = $false
        $script:notifyicon.dispose()
    }

    if ($script:primarypid) {
        Stop-Process -Id $PID, $script:primarypid
    }
}