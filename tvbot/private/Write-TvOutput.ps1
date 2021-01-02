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
        [string]$InputObject
    )
    process {
        if (-not $writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        # automatically set variables
        $config = Get-TvConfig
        foreach ($name in ($config | Get-Member -MemberType NoteProperty).Name) {
            $null = Set-Variable -Name $name -Value $config.$name -Scope Local
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
        $emote = $hash["emotes"]
        $emoteonly = [bool]$hash["emote-only"]

        Write-Verbose $InputObject
        # format it
        switch ($command) {
            "USERNOTICE" {
                $user = $displayname
                $sysmsg = $hash["system-msg"]
                if ($sysmsg -match "raiders") {
                    $image = Get-Avatar

                    # 15\sraiders\sfrom\sTdanni_juhl\shave\sjoined\n!
                    $text = $sysmsg.Replace("\s"," ").Replace("\n","")
                    $appicon = New-BTImage -Source $raidicon -AppLogoOverride

                    $heroimage = New-BTImage -Source $raidimage -HeroImage

                    $titletext = New-BTText -Text "$displayname $raidtext"
                    $thankstext = New-BTText -Text $text

                    $audio = New-BTAudio -Source $raidsound

                    $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                    $visual = New-BTVisual -BindingGeneric $binding
                    $content = New-BTContent -Visual $visual -Audio $audio
                    Submit-BTNotification -Content $content -UniqueIdentifier $id
                }
            }
            "PRIVMSG" {
                if ($message) {
                    if ($user) {
                        Write-Verbose "Display name: $displayname"
                        Write-Output "[$(Get-Date)] <$user> $message"

                        if ($notifytype -contains "chat" -and $user -notin $botstoignore) {
                            if ($message) {
                                try {
                                    # THANK YOU @vexx32!
                                    $string = ($message -replace '\x01').Replace("ACTION ", "")
                                    $id = "tvbot"
                                    $image = (Resolve-Path "$script:ModuleRoot\icon.png")

                                    if ($script:toast) {
                                        $image = Get-Avatar

                                        Write-Verbose "EMOTE: $emote"
                                        Write-Verbose "EMOTE ONLY: $emoteonly"

                                        if ($emote) {
                                            $emote, $location = $emote.Split(":")

                                            if (-not $emoteonly) {
                                                $location = $location.Split(",")
                                                Write-Verbose "$location"
                                                foreach ($match in $location) {
                                                    $first, $last = $match.Split("-")
                                                    # Thanks milb0!
                                                    $remove = $message.Substring($first, $last - $first + 1)
                                                    $string = $message.Replace($remove, "")
                                                }
                                            }

                                            $image = Get-TvEmote -Id $emote
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
                                            $appicon = New-BTImage -Source $bitsicon -AppLogoOverride
                                            $heroimage = New-BTImage -Source $bitsimage -HeroImage

                                            $titletext = New-BTText -Text $bitstitle
                                            $thankstext = New-BTText -Text "$bitstext $bigolbits $bitword, $displayname!"

                                            $audio = New-BTAudio -Source $bitssound

                                            $binding = New-BTBinding -Children $titletext, $thankstext -HeroImage $heroimage -AppLogoOverride $appicon
                                            $visual = New-BTVisual -BindingGeneric $binding
                                            $content = New-BTContent -Visual $visual -Audio $audio

                                            Submit-BTNotification -Content $content -UniqueIdentifier $id
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
                    if (-not $notifytype -or $message -eq "!quit") {
                        Invoke-TvCommand -InputObject $message -Channel $botchannel -Owner $botowner -User $user
                    }
                }
            }
            "JOIN" {
                Write-Output "[$(Get-Date)] *** $user has joined #$botchannel"

                if ($notifytype -contains "join") {
                    Send-OSNotification -Title $user -Body "$user has joined" -Icon (Resolve-Path "$script:ModuleRoot\icon.png")
                }
            }
            "PART" {
                Write-Output "[$(Get-Date)] *** $user has left #$botchannel"

                if ($notifytype -contains "leave") {
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