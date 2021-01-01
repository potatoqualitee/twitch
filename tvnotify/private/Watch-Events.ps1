function Watch-Events {
    <#
    .SYNOPSIS
        Watches for
        # follows
        # subs
        # bits
        # raids - https://dev.twitch.tv/docs/irc#usernotice-twitch-tags
#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Channel = "potatoqualitee"
    )
    process {
        Write-Verbose $Channel
        $id = (Invoke-TvRequest -Path /users?login=$Channel).data.id

        $subs = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$id -Verbose).data
        $follows = (Invoke-TvRequest -Path /users/follows?to_id=$id).data
        $subs
        return


        $latestfollower = $script:follows | Select-Object -First 1
        $script:follows = (Invoke-TvRequest -Path /users/follows?to_id=$id).data

        $script:follows
    }
}