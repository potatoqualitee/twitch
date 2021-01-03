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
    param()
    begin {

    }
    process {
        $id = (Get-TvUser).id

        $subs = Get-TvSubscriber
        $follows = Get-TvFollower


        $latestfollower = $script:follows | Select-Object -First 1
        $script:follows = (Invoke-TvRequest -Path /users/follows?to_id=$id).data

        $script:follows
    }
}