function Write-TvSystemMessage {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [string]$Message,
        [ValidateSet("Verbose")]
        [string]$Type
    )
    process {
        switch ($Type) {
            "Verbose" {
                Write-Verbose -Message "[$(Get-Date)] $Message"
                $null = $script:logger.Info($Message)
            }
        }
    }
}