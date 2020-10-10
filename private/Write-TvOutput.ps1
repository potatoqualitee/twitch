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
        [string[]]$Owner = $script:Owner
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

        # format it
        switch ($command) {
            "PRIVMSG" {
                if ($message) {
                    if ($user) {
                        Write-Output "[$(Get-Date)] <$user> $message"
                    } else {
                        Write-Output "[$(Get-Date)] > $message"
                    }
                    Invoke-TvCommand -InputObject $message -Channel $script:Channel -Owner $Owner -User $user
                }
            }
            "JOIN" {
                Write-Output "[$(Get-Date)] *** $user has joined #$script:Channel"
            }
            "PING" {
                Send-Server -Message "PONG"
                Write-Output -InputObject "[$(Get-Date)] PONG!"
            }
            353 {
                $members = $message.Split(" ")
                if ($members.Count -le 100) {
                    Write-Output "[$(Get-Date)] > Current user list:"
                    foreach ($member in $members) {
                        Write-Output "  $member"
                    }
                } else {
                    Write-Output "[$(Get-Date)] User list is super long, skipping"
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