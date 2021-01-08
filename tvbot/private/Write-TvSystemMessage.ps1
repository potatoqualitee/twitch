function Write-TvSystemMessage {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [string]$Message,
        [ValidateSet("Verbose", "Debug")]
        [string]$Type
    )
    process {
        switch ($Type) {
            "Verbose" {
                Write-Verbose -Message "[$(Get-Date)] $Message"
                $null = $script:logger.Info($Message)
            }
            "Debug" {
                Write-Debug -Message "[$(Get-Date)] $Message"
                $null = $script:logger.Debug($Message)
            }
        }
    }
}