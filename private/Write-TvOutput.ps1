function Write-TvOutput {
    <#
    .SYNOPSIS
        This command parses output from the server and writes it to console

    .DESCRIPTION
        This command parses output from the server and writes it to console

    .PARAMETER InputObject
        The data from the server

    .PARAMETER Channel
        The channel to post to

    .PARAMETER Owner
        The admins of the bot

    .EXAMPLE
        PS> Wait-TvInput
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory)]
        [string]$InputObject,
        [string]$Channel = $script:Channel,
        [string[]]$Owner = $script:Owner,
        [ValidateSet("chat", "leave", "join")]
        [string[]]$Notify
    )
    process {
        if (-not $writer.BaseStream) {
            throw "Have you connected to a server using Connect-TvServer?"
        }

        $irctagregex = [Regex]::new('^(?:@([^ ]+) )?(?:[:]((?:(\w+)!)?\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$')
        $match = $irctagregex.Match($InputObject) #tags = 1
        $prefix = $match.Groups[2].Value
        $user = $match.Groups[3].Value
        $command = $match.Groups[4].Value
        $params = $match.Groups[5].Value
        $message = $match.Groups[6].Value

        $hash = @{}
        # Thanks mr mark!
        $InputObject.split(';') | ForEach-Object {
            $split = $PSItem.Split('=')
            $key = $split[0]
            $value = $split[1]
            if (-not $hash[$key]) {
                $hash.Add($key,$value)
            }
        }
        $displayname = $hash["display-name"]

        Write-Verbose $InputObject
        # format it
        switch ($command) {
            "USERNOTICE" {
                <#
                @badge-info=subscriber/20;badges=moderator/1,subscriber/0;color=;display-name=danni_juhl;emotes=;flags=;id=12b7b085-b500-45da-b5fc-ca63e279823a;login=danni_j
                uhl;mod=1;msg-id=raid;msg-param-displayName=danni_juhl;msg-param-login=danni_juhl;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/64
                be776a-4ba1-476f-8ef2-b2a5251618d2-profile_image-70x70.png;msg-param-viewerCount=1;room-id=403789625;subscriber=1;system-msg=1\sraiders\sfrom\sdanni_juhl\sha
                ve\sjoined!;tmi-sent-ts=1608913632659;user-id=431422221;user-type=mod :tmi.twitch.tv USERNOTICE #potatoqualitee
                VERBOSE: [12/25/2020 17:28:44] command: USERNOTICE
                VERBOSE: [12/25/2020 17:28:44] message:
                #>
                $user = $displayname

                $sysmsg = $hash["system-msg"]
                if ($sysmsg -match "raiders") {
                    if ($script:cache[$user]) {
                        $image = $script:cache[$user]
                    } else {
                        $avatar = Invoke-TvRequest -Path /users?login=$user
                        $image = $avatar.data.profile_image_url
                        $script:cache[$user] = $image
                    }

                    $text = $sysmsg.Replace("\s"," ").Replace("\n","")
                    # 15\sraiders\sfrom\sTestChannel\shave\sjoined\n!
                    $appicon = New-BTImage -Source 'https://img.redbull.com/images/c_fill,g_auto,w_860,h_860/q_auto,f_auto/redbullcom/2017/06/19/3965fbe6-3488-40f8-88bc-b82eb8d1a230/pogchamp-twitch.png' -AppLogoOverride

                    $heroimage = New-BTImage -Source $image.Replace("300x300","70x70") -HeroImage

                    $titletext = New-BTText -Text "$displayname HAS RAIDED!"
                    $thankstext = New-BTText -Text $text

                    $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                    $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                    $visual = New-BTVisual -BindingGeneric $binding
                    $content = New-BTContent -Visual $visual -Audio $audio
                    Submit-BTNotification -Content $content
                    Write-Verbose "GOT HERE"
                }
            }
            "PRIVMSG" {
                if ($message) {
                    if ($user) {
                        Write-Verbose "Display name: $displayname"
                        Write-Output "[$(Get-Date)] <$user> $message"

                        if ($Notify -contains "chat") {
                            if ($message) {
                                try {
                                    # THANK YOU @vexx32!
                                    $string = ($message -replace '\x01').Replace("ACTION ", "")
                                    $id = "tvbot"
                                    $image = (Resolve-Path "$script:ModuleRoot\icon.png")

                                    if ($script:burnt) {
                                        if ($script:cache[$user]) {
                                            $image = $script:cache[$user]
                                        } else {
                                            $avatar = Invoke-TvRequest -Path /users?login=$user
                                            $image = $avatar.data.profile_image_url
                                            $script:cache[$user] = $image
                                        }
                                        $existingtoast = Get-BTHistory -UniqueIdentifier $id
                                        if ($existingtoast) {
                                            Remove-BTNotification -Tag $id -Group $id
                                        }

                                        $bigolbits = [int]$hash["bits"]

                                        if ($bigolbits -gt 0) {
                                            if ($bigolbits -eq 1) {
                                                $bitword = "BIT"
                                            } else {
                                                $bitword = "BITS"
                                            }
                                            $appicon = New-BTImage -Source 'https://steamuserimages-a.akamaihd.net/ugc/910168207873457772/65EBE052D0B8DDB3F09F3034E28B6A2A2CA75DCB/' -AppLogoOverride

                                            $heroimage = New-BTImage -Source $image.Replace("300x300","70x70") -HeroImage

                                            $titletext = New-BTText -Text "MERCI BEAUCOUP"
                                            $thankstext = New-BTText -Text "THANK YOU FOR THE $bigolbits $bitword, $displayname!!"

                                            $audio = New-BTAudio -Source 'ms-winsoundevent:Notification.Mail'

                                            $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                                            $visual = New-BTVisual -BindingGeneric $binding
                                            $content = New-BTContent -Visual $visual -Audio $audio

                                            Submit-BTNotification -Content $content
                                            Remove-BTNotification -Tag $id -Group $id
                                            # parse out if they said more than just the bit so that you can show that
                                        } else {
                                            try {
                                                New-BurntToastNotification -AppLogo $image -Text $displayname, $string -UniqueIdentifier $id -ErrorAction Stop
                                            } catch {

                                            }
                                        }
                                    } else {
                                        $string = [System.Security.SecurityElement]::Escape($message)
                                        Send-OSNotification -Title $user -Body $string -Icon $image -ErrorAction Stop
                                    }
                                } catch {
                                    $_
                                }
                            }
                        }
                    } else {
                        Write-Output "[$(Get-Date)] > $message"
                    }
                    if (-not $Notify -or $message -eq "!quit") {
                        Invoke-TvCommand -InputObject $message -Channel $script:Channel -Owner $Owner -User $user
                    }
                }
            }
            "JOIN" {
                Write-Output "[$(Get-Date)] *** $user has joined #$script:Channel"

                if ($Notify -contains "join") {
                    Send-OSNotification -Title $user -Body "$user has joined" -Icon (Resolve-Path "$script:ModuleRoot\icon.png")
                }
            }
            "PART" {
                Write-Output "[$(Get-Date)] *** $user has left #$script:Channel"

                if ($Notify -contains "leave") {
                    Send-OSNotification -Title $user -Body "$user has has left" -Icon (Resolve-Path "$script:ModuleRoot\icon.png")
                }
            }
            "PING" {
                $script:ping = [DateTime]::Now
                Send-Server -Message "PONG"
            }
            353 {
                $members = $message.Split(" ")
                if ($members.Count -le 100) {
                    Write-Output "[$(Get-Date)] > Current user list:"
                    foreach ($member in $members) {
                        Write-Output "  $member"
                    }
                } else {
                    Write-Verbose "[$(Get-Date)] > Current user list:"
                    foreach ($member in $members) {
                        Write-Verbose "  $member"
                    }
                }
            }
            { $psitem.Trim() -in 001, 002, 003, 372 } {
                Write-Output "[$(Get-Date)] > $message"
            }
            default {
                Write-Verbose "[$(Get-Date)] command: $command"
                Write-Verbose "[$(Get-Date)] message: $message"
                Write-Verbose "[$(Get-Date)] params: $params"
                Write-Verbose "[$(Get-Date)] prefix: $prefix"
                Write-Verbose "[$(Get-Date)] user: $user"
            }
        }
    }
}