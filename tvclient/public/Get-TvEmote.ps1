function Get-TvEmote {
    <#
    .SYNOPSIS
        Gets Twitch User

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
        [pscustomobject]@{
            EmoteId    = $id
            DarkTheme  = "https://static-cdn.jtvnw.net/emoticons/v2/$Id/default/dark/2.0"
            LightTheme = "https://static-cdn.jtvnw.net/emoticons/v2/$Id/default/light/2.0"
        }
    }
}