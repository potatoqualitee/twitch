

if (-not $PSBoundParameters.Channel) {
    if ($botowner.Count -eq 1) {
        $botchannel = "$botowner"
    } else {
        Write-Error -ErrorAction Stop -Message "You must specify a Channel when assigning multiple owners"
    }
}

if ($PSBoundParameters.ClientId -and $PSBoundParameters.Token) {
    $null = Invoke-TvRequest -ClientId $botclientid -Token $bottoken

    if ($script:toast1) {
        try {
            $id = (Invoke-TvRequest -Path /users?login=$botchannel -ErrorAction Stop).data.id
            $subs = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$id -ErrorAction Stop).data
            $follows = (Invoke-TvRequest -Path /users/follows?to_id=$id -ErrorAction Stop).data
        } catch {
            $failedcheck = $true
            Write-Warning "Error from webserver: $PSItem. Subs and follows will not be shown."
        }

        if (-not (Get-Job -Name tvbotviewers -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
            $null = Start-Job -Name tvbotviewers -ScriptBlock {
                param (
                    [string]$botclientid,
                    [string]$bottoken
                )
                Show-TvViewerCount -Client $botclientid -Token $bottoken
            } -ArgumentList $botclientid, $bottoken
        }

        if (-not $failedcheck) {
            if (-not (Get-Job -Name tvbotsubsfollows -ErrorAction SilentlyContinue | Where-Object State -eq Running)) {
                $null = Start-Job -Name tvbotsubsfollows -ScriptBlock {
                    param (
                        [string]$botclientid,
                        [string]$bottoken,
                        [int]$Id,
                        [psobject[]]$Subs,
                        [psobject[]]$Follows,
                        [string]$ModuleRoot
                    )
                    $null = Invoke-TvRequest -Client $botclientid -Token $bottoken

                    while ($true) {
                        Start-Sleep -Seconds 3

                        # Get updated lists of follows and subs
                        $subupdate = (Invoke-TvRequest -Path /subscriptions?broadcaster_id=$Id).data
                        $followerupdate = (Invoke-TvRequest -Path /users/follows?to_id=$Id).data

                        $newfollowers = $followerupdate | Where-Object from_name -notin $Follows.from_name
                        $newsubs = $subupdate | Where-Object user_name -notin $Subs.user_name

                        foreach ($follower in $newfollowers.from_name) {
                            $avatar = Invoke-TvRequest -Path /users?login=$follower
                            $appicon = New-BTImage -Source $avatar.data.profile_image_url -AppLogoOverride
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

                        $Subs = $subupdate
                        $Follows = $followerupdate
                    }
                } -ArgumentList $botclientid, $bottoken, $id, $subs, $follows, $script:ModuleRoot
            }
        }
    }
}