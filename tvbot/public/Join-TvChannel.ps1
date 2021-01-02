
function Join-TvChannel {
    <#
    .SYNOPSIS
        Joins a channel.

    .DESCRIPTION
        Joins a channel.

    .PARAMETER Channel
        The name of the channel.

    .EXAMPLE
        PS> Join-TvChannel -Channel mychannel
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory)]
        [string]$Channel
    )
    if (-not $writer.BaseStream) {
        Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
    }
    $script:Channel = $Channel
    foreach ($chan in $Channel) {
        if ($chan -notmatch '\#') {
            $chan = "#$chan"
        }
        Send-Server -Message "JOIN $chan"
    }
}