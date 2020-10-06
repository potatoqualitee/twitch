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
                        Write-Output "<$user> $message"
                    } else {
                        Write-Output "> $message"
                    }
                    Invoke-TvCommand -InputObject $message -Channel $script:Channel -Owner $Owner -User $user
                }
            }
            "JOIN" {
                Write-Output "*** $user has joined #$script:Channel"
            }
            353 {
                $members = $message.Split(" ")
                if ($members.Count -le 100) {
                    Write-Output "> Current user list:"
                    foreach ($member in $members) {
                        Write-Output "  $member"
                    }
                } else {
                    Write-Output "User list is super long, skipping"
                }
            }
            { $psitem.Trim() -in 001, 002, 003, 372 } {
                Write-Output "> $message"
            }
            default {
                Write-Verbose "command: $command"
                Write-Verbose "message: $message"
                Write-Verbose "params: $params"
                Write-Verbose "prefix: $prefix"
                Write-Verbose "user: $user"
            }
        }
    }
}