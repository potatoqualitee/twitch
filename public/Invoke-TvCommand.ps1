
function Invoke-TvCommand {
    <#
    .SYNOPSIS
        Invokes a command and reports text back to the channel

    .DESCRIPTION
        Invokes a command and reports text back to the channel

    .PARAMETER Channel
        The destionation channel where the messages will go

    .PARAMETER InputObject
        The message to parse for commands

    .PARAMETER Key
        The token that designates if a message is intended for the bot

    .PARAMETER UserCommand
        The commands that users are allowed to execute

    .PARAMETER AdminCommand
        The commands for admins

    .EXAMPLE
        PS> Invoke-TvCommand -Channel mychannel -Message "Test!"
    #>
    [CmdletBinding()]
    Param (
        [string]$Channel = $script:Channel,
        [parameter(Mandatory)]
        [string[]]$InputObject,
        [string[]]$Owner = $script:Owner,
        [string]$Key = "!",
        [string]$User,
        [object]$UserCommand = $script:UserCommand,
        [object]$AdminCommand = $script:AdminCommand,
        [ValidateSet("chat", "leave", "join")]
        [string[]]$Notify
    )
    process {
        if (-not $writer.BaseStream) {
            throw "Have you connected to a server using Connect-TvServer?"
        }

        # some defaults
        if (-not $UserCommand) {
            $UserCommand = @{
                ping = 'Send-TvMessage -Message "$user, pong"'
                pwd  = 'Send-TvMessage -Message $(Get-Location)'
            }
        }
        if (-not $AdminCommand) {
            $AdminCommand = @{
                quit = 'Disconnect-TvServer -Message "FINE!"'
            }
        }

        try {
            if ($UserCommand -isnot [hashtable]) {
                if ((Test-Path -Path $UserCommand -ErrorAction SilentlyContinue)) {
                    $UserCommand = Get-Content -Raw -Path $UserCommand | ConvertFrom-Json
                }
                $UserCommand = $UserCommand | ConvertTo-HashTable -ErrorAction Stop
            }
            if ($AdminCommand -isnot [hashtable]) {
                if ((Test-Path -Path $AdminCommand -ErrorAction SilentlyContinue)) {
                    $AdminCommand = Get-Content -Raw -Path $AdminCommand | ConvertFrom-Json
                }
                $AdminCommand = $AdminCommand | ConvertTo-HashTable -ErrorAction Stop
            }
        } catch {
            throw "Conversion for UserCommand and AdminCommand failed. Please check examples."
        }

        $allowedregex = [Regex]::new("^$Key[a-zA-Z0-9\ ]+`$")
        $irctagregex = [Regex]::new('^(?:@([^ ]+) )?(?:[:]((?:(\w+)!)?\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$')

        foreach ($object in $InputObject) {
            $match = $irctagregex.Match($object)

            if (-not $user) {
                $user = $match.Groups[3].Value
            }
            if ($user -and $object.StartsWith($Key) -and $allowedregex.Matches($object)) {
                $index = $object.Trim().Substring(1).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

                if ($index) {
                    $code = $UserCommand[$index[0]]
                    if (-not $code -and $user -in $Owner) {
                        $code = $AdminCommand[$index[0]]
                    }

                    try {
                        if ($code) {
                            Invoke-Expression $code
                        } else {
                            if (-not $Notify) {
                                write-warning "$notify"
                                Send-TvMessage -Message "$key$index is an invalid command" -Channel $Channel
                            }
                        }
                    } catch {
                        Send-TvMessage -Channel $Channel -Message "$($_.Exception.Message)"
                        Write-Output $_.Exception
                    }
                }
            } else {
                if ($PSBoundParameters.Notify) {
                    Write-TvOutput -InputObject $object -Channel $Channel -Notify $Notify
                } else {
                    Write-TvOutput -InputObject $object -Channel $Channel
                }
            }
        }
    }
    end {
        # clear out user
        $user = $null
    }
}