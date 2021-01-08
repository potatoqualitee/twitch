function Write-TvVerbose {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [string]$Message
    )
    process {
        Write-Verbose -Message $Message
        $null = $script:logger.Info($Message)
    }
}