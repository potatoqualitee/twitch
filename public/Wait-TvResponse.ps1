function Wait-TvResponse {
    <#
    .SYNOPSIS
        Waits for the IRC Server to send data.

    .DESCRIPTION
        Waits for the IRC Server to send data.

    .PARAMETER Channel
        Optional channel to listen in

    .PARAMETER Key
        The chracter for the bot to listen for. Exclamation point by default.

        !likethis
        >likethis
        ?likethis

    .PARAMETER UserCommand
        The commands that users can use. Input can be JSON, a filename with JSON or a hashtable.

    .PARAMETER AdminCommand
        The commands that admins can use. Input can be JSON, a filename with JSON or a hashtable.

    .EXAMPLE
        PS> $params = @{
            UserCommand  = "C:\temp\user-commands.json"
            AdminCommand = "C:\temp\admin-commands.json"
            Channel      = "mypsbot"
            Key          = ">"
        }

        Wait-TvResponse  @params
    #>
    [CmdletBinding()]
    param (
        [string]$Channel = $script:Channel,
        [string]$Key = "!",
        [object]$UserCommand = $script:UserCommand,
        [object]$AdminCommand = $script:AdminCommand
    )
    begin {
        $script:UserCommand = $UserCommand
        $script:AdminCommand = $AdminCommand
    }
    process {
        if (-not $script:line) {
            throw "Nothing to parse"
        }

        if (-not $writer.BaseStream) {
            throw "Have you connected to a server using Connect-TvServer?"
        }

        while ($null -ne $script:line) {
            try {
                $script:line = $reader.ReadLine()
                $params = @{
                    InputObject  = $script:line
                    Owner        = $script:Owner
                    UserCommand  = $script:UserCommand
                    AdminCommand = $script:AdminCommand
                    Channel      = $Channel
                    Key          = $Key
                }
                Invoke-TvCommand @params
            } catch {
                throw "Cannot read stream: $_"
            }
        }
    }
}