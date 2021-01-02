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
                $startingsubs = Get-TvSubscriber
                $startingFollows = Get-TvFollower
            } catch {
                Write-Error -ErrorRecord $_ -ErrorAction Stop -Message "Error from webserver: $PSItem. Subs and follows will not be shown."
            }

            if (-not (Get-Job -Name tvbotviewers -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotviewers -ScriptBlock {
                    Show-TvViewerCount
                }
            }

            if (-not (Get-Job -Name tvbotsubsfollows -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotsubsfollows -ScriptBlock {
                    param (
                        [psobject[]]$Startingsubs,
                        [psobject[]]$StartingFollows,
                        [string]$ModuleRoot
                    )
                    while ($true) {
                        Start-Sleep -Seconds 3

                        # Get updated lists of follows and subs
                        $subupdate = Get-TvSubscriber
                        $followerupdate = Get-TvFollower

                        $newfollowers = $followerupdate | Where-Object FromName -notin $startingFollows.FromName
                        $newsubs = $subupdate | Where-Object Username -notin $startingsubs.UserName

                        foreach ($follower in $newfollowers.FromName) {
                            $avatar = Get-TvUser -UserName $follower
                            $appicon = New-BTImage -Source $avatar.ProfileImageUrl -AppLogoOverride
                            $heroimage = New-BTImage -Source "$ModuleRoot\images\catparty.gif" -HeroImage

                            $titletext = New-BTText -Text "NEW FOLLOWER!"
                            $thankstext = New-BTText -Text "THANK YOU FOR THE FOLLOW, $follower!!"

                            $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                            $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                            $visual = New-BTVisual -BindingGeneric $binding
                            $content = New-BTContent -Visual $visual -Audio $audio

                            Submit-BTNotification -Content $content -UniqueIdentifier $id
                            Write-Warning WAITING
                            Start-Sleep 5
                        }

                        foreach ($sub in $newsubs) {
                            $subscriber = $sub.user_name
                            <#
                                        gifter_name      :
                                        is_gift          : False
                                        plan_name        : Channel Subscription (potatoqualitee)
                                        tier             : 1000
                                        user_id          : 210963797
                                        user_name        : owenkbcodes
                                    #>
                            $avatar = Invoke-TvRequest -Path /users?login=$subscriber
                            $appicon = New-BTImage -Source $avatar.data.profile_image_url -AppLogoOverride
                            $heroimage = New-BTImage -Source "$ModuleRoot\images\catparty.gif" -HeroImage

                            $titletext = New-BTText -Text "NEW SUB!"
                            $thankstext = New-BTText -Text "THANK YOU FOR THE subscription, $subscriber!!"

                            $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                            $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                            $visual = New-BTVisual -BindingGeneric $binding
                            $content = New-BTContent -Visual $visual -Audio $audio

                            Submit-BTNotification -Content $content -UniqueIdentifier $id
                        }

                        $startingsubs = $subupdate
                        $startingFollows = $followerupdate
                    }
                } -ArgumentList $startingsubs, $startingFollows, $script:ModuleRoot
            }
        }
    }
}
