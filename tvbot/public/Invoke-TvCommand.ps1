
function Invoke-TvCommand {
    <#
    .SYNOPSIS
        Invokes a command and reports text back to the channel

    .DESCRIPTION
        Invokes a command and reports text back to the channel

    .PARAMETER InputObject
        The message to parse for commands

    .PARAMETER User
        The username invoking the command

    .EXAMPLE
        PS> $InputObject | Invoke-TvCommand -User potatoqualitee

        Processes a complex string from IRC and checks to see if potatoqualitee is qualified to run the command
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string[]]$InputObject,
        [string]$User
    )
    process {
        if (-not $script:writer.BaseStream) {
            Write-Error -ErrorAction Stop -Message "Have you connected to a server using Connect-TvServer?"
        }

        # automatically set variables
        $config = Get-TvConfig
        foreach ($name in ($config | Get-Member -MemberType NoteProperty).Name) {
            $null = Set-Variable -Name $name -Value $config.$name -Scope Local
        }

        $usercommand = Get-UserCommand
        $admincommand = Get-AdminCommand

        $allowedregex = [Regex]::new("^$([Regex]::Escape($botkey))[a-zA-Z0-9\ ]+`$")
        $irctagregex = [Regex]::new('^(?:@([^ ]+) )?(?:[:]((?:(\w+)!)?\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$')

        foreach ($object in $InputObject) {
            $match = $irctagregex.Match($object)
            if (-not $PSBoundParameters.User) {
                $User = $match.Groups[3].Value
            }
            if ($user -and $object.StartsWith($botkey) -and $allowedregex.Matches($object)) {
                $index = $object.Trim().Substring(1).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

                if ($index) {
                    $code = $usercommand[$index[0]]
                    if (-not $code -and $user -in $botowner) {
                        Write-TvSystemMessage -Type Verbose -Message "Getting admin command"
                        $code = $admincommand[$index[0]]
                    }

                    try {
                        if ($code) {
                            Write-TvSystemMessage -Type Verbose -Message "Executing $code"
                            Invoke-Expression -Command $code
                        }
                    } catch {
                        Write-TvChannelMessage -Message "$($_.Exception.Message)"
                        Write-Output $_.Exception
                    }
                }
            } else {
                Write-TvOutput -InputObject $object
            }
        }
    }
}