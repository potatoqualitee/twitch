function Show-TvAlert {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param ()
    begin {
        $PSDefaultParameterValues["*:ErrorAction"] = "Stop"
    }
    process {
        if ($script:toast) {
            try {
                $StartingSubs = Get-TvSubscriber
                $startingFollows = Get-TvFollower
            } catch {
                throw "Error from webserver: $PSItem. Subs and follows will not be shown."
            }

            if (-not (Get-Job -Name tvbotviewers -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotviewers -ScriptBlock {
                    Show-TvViewerCount
                }
            }

            if (-not (Get-Job -Name tvbotsubsfollows -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotsubsfollows -ScriptBlock {
                    param (
                        [psobject[]]$StartingSubs,
                        [psobject[]]$StartingFollows,
                        [string]$ModuleRoot
                    )
                    while ($true) {
                        Start-Sleep -Seconds 3

                        # Get updated lists of follows and subs
                        $subupdate = Get-TvSubscriber
                        $followerupdate = Get-TvFollower

                        $newfollowers = $followerupdate | Where-Object FromName -notin $startingFollows.FromName
                        $newsubs = $subupdate | Where-Object Username -notin $StartingSubs.UserName

                        foreach ($follower in $newfollowers.FromName) {
                            Show-Alert -UserName $follower -Type Follow
                            Start-Sleep 5
                        }

                        foreach ($sub in $newsubs) {
                            <#
                            UserName        : TonyPzzzy
                            BroadcasterId   : 403789625
                            BroadcasterName : potatoqualitee
                            GifterId        : 237082391
                            GifterName      : MarvRobot
                            IsGift          : True
                            PlanName        : Channel Subscription (potatoqualitee)
                            Tier            : 1000
                            UserId          : 77563512

                            UserName        : NickTheFirstOne
                            BroadcasterId   : 403789625
                            BroadcasterName : potatoqualitee
                            GifterId        : 274598607
                            GifterName      : AnAnonymousGifter
                            IsGift          : True
                            PlanName        : Channel Subscription (potatoqualitee)
                            Tier            : 1000
                            UserId          : 42402976

                            Select UserName, Tier, GifterName
                            #>
                            $tier = $sub.Tier.ToCharArray() | Select-Object -First 1

                            if ($sub.GifterName) {
                                $username = $sub.GifterName
                                $message = ""
                                Show-Alert -UserName $username -Type Sub -Tier $tier -Title $message
                            } else {
                                $username = $sub.UserName
                                Show-Alert -UserName $username -Type Sub -Tier $tier
                            }
                        }

                        $StartingSubs = $subupdate
                        $startingFollows = $followerupdate
                    }
                } -ArgumentList $StartingSubs, $startingFollows, $script:ModuleRoot
            }
        }
    }
}
