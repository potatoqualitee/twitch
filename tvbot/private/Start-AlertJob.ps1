function Start-AlertJob {
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
            if (-not (Get-Job -Name tvbotviewers -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotviewers -ScriptBlock {
                    Show-TvViewerCount
                }
            }

            if (-not (Get-Job -Name tvbotsubsfollows -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotsubsfollows -ScriptBlock {
                    $StartingSubs = Get-TvSubscriber
                    $startingFollows = Get-TvFollower

                    while ($true) {
                        Start-Sleep -Seconds 3

                        # Get updated lists of follows and subs
                        $subupdate = Get-TvSubscriber
                        $followerupdate = Get-TvFollower

                        $newfollowers = $followerupdate | Where-Object FromName -notin $startingFollows.FromName
                        $newsubs = $subupdate | Where-Object Username -notin $StartingSubs.UserName

                        foreach ($follower in $newfollowers.FromName) {
                            Start-AlertJob -UserName $follower -Type Follow
                        }

                        foreach ($sub in $newsubs) {
                            $tier = $sub.Tier.ToCharArray() | Select-Object -First 1

                            if ($sub.GifterName) {
                                Start-AlertJob -UserName $sub.GifterName -Type SubGifted -MiscNumber $tier -MiscString $sub.UserName
                            } else {
                                Start-AlertJob -UserName $sub.UserName -Type Sub -MiscNumber $tier
                            }
                        }

                        $StartingSubs = $subupdate
                        $startingFollows = $followerupdate
                    }
                }
            }
        }
    }
}
