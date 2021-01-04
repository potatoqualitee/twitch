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

        # parse the return from the server
        $irctagregex = [Regex]::new('^(?:@([^ ]+) )?(?:[:]((?:(\w+)!)?\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$')
        $match = $irctagregex.Match($InputObject) #tags = 1
        $prefix = $match.Groups[2].Value
        $user = $match.Groups[3].Value
        $command = $match.Groups[4].Value
        $params = $match.Groups[5].Value
        $message = $match.Groups[6].Value

        # Gather additional information
        # Thanks mr mark!
        $hash = @{}
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
                $sysmsg = $hash["system-msg"]
                if ($sysmsg -match "raiders") {
                    # $sysmsg = '15\sraiders\sfrom\sdanni_juhl\shave\sjoined\n!'
                    $text = $sysmsg.Replace("\s"," ").Replace("\n","")
                    Show-Alert -Type Message -UserName $displayname -Message $text
                }
            }
            "PRIVMSG" {
                if ($message) {
                    if ($user) {
                        Write-Verbose "Display name: $displayname"
                        Write-Output "[$(Get-Date)] <$user> $message"

                        if ($notifytype -contains "chat" -and $user -notin $botstoignore) {
                            $bigolbits = [int]$hash["bits"]

                            if ($bigolbits -gt 0) {
                                Show-Alert -Type Bits -UserName $displayname -Bits $bigolbits
                            }

                            if ($emote) {
                                # @badge-info=;badges=premium/1;color=#0089FF;display-name=potatoqualitee;emote-only=1;emotes=425618:0-2;flags=;id=0902c83d
                                Write-Verbose "EMOTE: $emote"
                                Write-Verbose "EMOTE ONLY: $emoteonly"
                                $emote, $location = $emote.Split(":")

                                if (-not $emoteonly) {
                                    $location = $location.Split(",")
                                    Write-Verbose "$location"
                                    foreach ($match in $location) {
                                        $first, $last = $match.Split("-")
                                        # Thanks milb0!
                                        $remove = $message.Substring($first, $last - $first + 1)
                                        $message = $message.Replace($remove, "")
                                    }
                                }
                                Show-Alert -Type Message -UserName $displayname -Message $message -Emote $emote
                            }

                            if ($message) {
                                # THANK YOU @vexx32!
                                $message = ($message -replace '\x01').Replace("ACTION ", "")
                                Show-Alert -Type Message -UserName $displayname -Message $message
                            }
                        }
                    } else {
                        Write-Output "[$(Get-Date)] > $message"
                    }
                    if ($notifytype -ne "none" -or $message -eq "!quit") {
                        Invoke-TvCommand -InputObject $message -User $user
                    }
                }
            }
            "JOIN" {
                Write-Output "[$(Get-Date)] *** $user has joined #$botchannel"

                if ($notifytype -contains "join") {
                    Show-Alert -UserName $displayname -Message "$user has joined" -Type Message
                }
            }
            "PART" {
                Write-Output "[$(Get-Date)] *** $user has left #$botchannel"

                if ($notifytype -contains "leave") {
                    Show-Alert -UserName $displayname -Message "$user has has left" -Type Message
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