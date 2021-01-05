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
            # Clean up multi line
            if ($Message -match "`n") {
                $Message = $Message.Replace("`n"," ")
                $Message = $Message.Replace("`r"," ")
                $Message = $Message.Replace("`t"," ")
                do {
                    $Message = $Message.Replace("  "," ")
                } until ($Message -notmatch "  ")
            }
            Send-Server -Message "PRIVMSG #$channel :$Message"
            Show-TvAlert -Message $Message -Type Message -UserName $script:botname
        }
    } else {
        Write-Error -ErrorAction Stop -Message "Disconnected?"
    }
}