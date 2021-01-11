function Write-TvChannelMessage {
    <#
    .SYNOPSIS
        Writes a message to a channel

    .DESCRIPTION
        Writes a message to a channel

    .PARAMETER Message
        The message to send

    .EXAMPLE
        PS> Write-TvChannelMessage -Message "Test!"

        Writes "Test!" to the channel configured in BotChannel
    #>
    [CmdletBinding()]
    param (
        [string]$Message
    )
    process {
        if (-not $script:writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        $botchannel = Get-TvConfigValue -Name BotChannel

        if ($null -ne $script:writer.BaseStream) {
            foreach ($channel in $botchannel) {
                # Clean up multi line
                # irc doesnt allow multi-line and twitch can potentially throttle
                if ($Message -match "`n") {
                    $Message = $Message.Replace("`n"," ")
                    $Message = $Message.Replace("`r"," ")
                    $Message = $Message.Replace("`t"," ")
                    do {
                        $Message = $Message.Replace("  "," ")
                    } until ($Message -notmatch "  ")
                }
                Send-Server -Message "PRIVMSG #$channel :$Message"

                if ((Get-TvConfigValue -Name NotifyType) -ne "none") {
                    Show-TvAlert -Message $Message -Type Message -UserName $script:botname
                }

            }
        } else {
            Write-Error -ErrorAction Stop -Message "Disconnected?"
        }
    }
}