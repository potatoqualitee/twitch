function Write-TvChannelMessage {
    <#
    .SYNOPSIS
        Writes a message to a channel.

    .DESCRIPTION
        Writes a message to a channel.

    .EXAMPLE
        PS> Write-TvChannelMessage -Message "Test!"
    #>
    [CmdletBinding()]
    param (
        [string]$Message
    )

    if (-not $writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }

    $botchannel = Get-TvConfigValue -Name BotChannel

    if ($null -ne $writer.BaseStream) {
        foreach ($channel in $botchannel) {
            Write-Verbose -Message "[$(Get-Date)] PRIVMSG #$channel :$Message"
            Send-Server -Message "PRIVMSG #$channel :$Message"
        }
    } else {
        Write-Error -ErrorAction Stop -Message "Disconnected?"
    }
}