function Get-TvEmote {
    <#
    .SYNOPSIS
        Returns the emote web URI for Dark and Light themes

    .DESCRIPTION
        Returns the emote web URI for Dark and Light themes

    .PARAMETER Id
        The Id of the target emote

    .EXAMPLE
        PS> Get-TvEmote -Id 425618

        Gets the web addresses for emote id 425618 (LUL)

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("EmoteId")]
        [Alias("Emote")]
        [int[]]$Id
    )
    process {
        foreach ($emoteid in $id) {
            [pscustomobject]@{
                EmoteId = $emoteid
                Dark    = "https://static-cdn.jtvnw.net/emoticons/v2/$Id/default/dark/2.0"
                Light   = "https://static-cdn.jtvnw.net/emoticons/v2/$Id/default/light/2.0"
            }
        }
    }
}