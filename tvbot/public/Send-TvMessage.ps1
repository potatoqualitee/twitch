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
        [string]$Channel,
        [string]$Message
    )

    if (-not $writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }

    if ($null -ne $writer.BaseStream) {
        foreach ($room in $Channel) {
            Write-Verbose -Message "[$(Get-Date)] PRIVMSG #$room :$Message"
            Send-Server -Message "PRIVMSG #$room :$Message"
        }
        if (-not $PSBoundParameters.Channel) {
            Write-Verbose -Message "[$(Get-Date)] PRIVMSG :$Message"
            Send-Server -Message "PRIVMSG :$Message"
        }
    } else {
        Write-Error -ErrorAction Stop -Message "Disconnected?"
    }
}