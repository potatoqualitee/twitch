function Write-TvVerbose {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [string]$Message,
        [switch]$NoLog
    )
    process {
        $Message = "[$(Get-Date)] $Message"
        Write-Verbose -Message $Message
        if (-not $NoLog) {
            $script:logger.Info($Message)
            #[log4net.LogManager]::Flush([int]::MaxValue)
        }
    }
}