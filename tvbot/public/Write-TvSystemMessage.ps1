function Write-TvSystemMessage {
    <#
    .SYNOPSIS
        Writes output to console and log

    .DESCRIPTION
        Writes output to console and log

    .PARAMETER Message
        The message

    .PARAMETER Type
        Verbose or debug
    #>
    [CmdletBinding()]
    param
    (
        [string]$Message,
        [ValidateSet("Verbose", "Debug")]
        [string]$Type = "Verbose"
    )
    process {
        switch ($Type) {
            "Verbose" {
                $null = $script:logger.Info($Message)
                Write-Verbose -Message "[$(Get-Date)] $Message"
            }
            "Debug" {
                $null = $script:logger.Debug($Message)
                Write-Debug -Message "[$(Get-Date)] $Message"
            }
        }
    }
}