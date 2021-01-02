
function Split-TvChannel {
    <#
    .SYNOPSIS
        Leaves a channel.

    .DESCRIPTION
        Leaves a channel.

    .PARAMETER Channel
        The channel to leave.

    .EXAMPLE
        PS> Split-TvChannel -Channel mychannel
    #>
    [CmdletBinding()]
    Param (
        [string]$Channel
    )
    if (-not $writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }
    foreach ($room in $Channel) {
        if ($room -notmatch '\#') {
            $room = "#$room"
        }
        Write-TvChannelMessage -Message "Leaving"
        Send-Server -Message "LEAVE $room"
    }
}