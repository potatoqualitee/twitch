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

                    Write-TvSystemMessage -Type Verbose -Message "Got $($StartingSubs.Count) subs"
                    Write-TvSystemMessage -Type Verbose -Message "Got $($startingFollows.Count) follows"

                    while ($true) {
                        Start-Sleep -Seconds 2

                        # Get updated lists of follows and subs
                        $subupdate = Get-TvSubscriber
                        $followerupdate = Get-TvFollower

                        $newfollowers = $followerupdate | Where-Object FromName -notin $startingFollows.FromName
                        $newsubs = $subupdate | Where-Object Username -notin $StartingSubs.UserName

                        foreach ($follower in $newfollowers.FromName) {
                            Show-TvAlert -UserName $follower -Type Follow
                            Write-TvSystemMessage -Type Verbose -Message "New follower: $follower!"
                        }

                        foreach ($sub in $newsubs) {
                            $tier = $sub.Tier
                            if ($sub.GifterName) {
                                Show-TvAlert -UserName $sub.GifterName -Type SubGifted -MiscNumber $tier -MiscString $sub.UserName

                                Write-TvSystemMessage -Type Verbose -Message "New Tier $tier sub gifted from $($sub.GifterName) to $($sub.UserName)!"
                            } else {
                                Show-TvAlert -UserName $sub.UserName -Type Sub -MiscNumber $tier
                                Write-TvSystemMessage -Type Verbose -Message "New Tier $tier sub: $($sub.UserName)!"
                            }
                        }

                        if ($newsubs -or $newfollowers) {
                            # Allow a person to custom code
                            # Use Get-Variable to see all of the variables that
                            # are available.
                            $cmd = Get-TvConfigValue -Name ScriptsToProcess
                            if ($cmd) {
                                if ((Test-Path -Path $cmd)) {
                                    foreach ($file in $cmd) {
                                        Write-TvSystemMessage -Type Verbose -Message "Executing $file"
                                        $externalcode = Get-Content -Path $file -Raw
                                        Invoke-Expression -Command $externalcode
                                    }
                                }
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