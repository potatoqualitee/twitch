
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
        [parameter(Mandatory)]
        [string]$Channel
    )
    if (-not $writer.BaseStream) {
        throw "Have you connected to a server using Connect-TvServer?"
    }
    foreach ($chan in $script:Channel) {
        if ($chan -notmatch '\#') {
            $chan = "#$chan"
        }
        Send-Server -Message "LEAVE $chan"
    }

    $script:Channel = $null
}