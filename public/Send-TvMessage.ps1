function Send-TvMessage {
    <#
    .SYNOPSIS
        Writes a message to a channel.

    .DESCRIPTION
        Writes a message to a channel.

    .EXAMPLE
        PS> Send-TvMessage -Channel mychannel -Message "Test!"
    #>
    [CmdletBinding()]
    param (
        [string]$Channel = $script:Channel,
        [string]$Message
    )

    if (-not $writer.BaseStream) {
        throw "Have you connected to a server using Connect-TvServer?"
    }

    if ($null -ne $writer.BaseStream) {
        foreach ($chan in $Channel) {
            Write-Verbose -Message "PRIVMSG #$chan :$Message"
            Send-Server -Message "PRIVMSG #$chan :$Message"
        }
    } else {
        throw "Disconnected?"
    }
}