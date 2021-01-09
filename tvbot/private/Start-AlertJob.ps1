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
                            Show-TvAlert -UserName $follower -Type Follow
                        }

                        foreach ($sub in $newsubs) {
                            $tier = $sub.Tier.ToCharArray() | Select-Object -First 1

                            if ($cmd) {
                                if ((Test-Path -Path $cmd)) {
                                    foreach ($file in $cmd) {
                                        Write-Verbose -Message "Executing $file"
                                        $externalcode = Get-Content -Path $file -Raw
                                        Invoke-Expression -Command $externalcode
                                    }
                                }
                            }

                            if ($sub.GifterName) {
                                Show-TvAlert -UserName $sub.GifterName -Type SubGifted -MiscNumber $tier -MiscString $sub.UserName
                            } else {
                                Show-TvAlert -UserName $sub.UserName -Type Sub -MiscNumber $tier
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
                                        Write-Verbose -Message "Executing $file"
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