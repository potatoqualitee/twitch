function Send-TvDiscordMessage {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param (
        [string]$Message
    )
    process {
        $url = Get-TvConfigValue -Name DiscordWebhook
        if (-not $url) {
            Write-Error -ErrorAction Stop -Message "You must set a DiscordWebhook using Set-TvConfig -DiscordWebhook https://WEBHOOK"
        }

        Write-TvSystemMessage -Type Verbose -Message "Sending '$Message' to Discord"
        # verbose disabled any further because it exposes the key
        $VerbosePreference = "SilentlyContinue"

        $body = [pscustomobject]@{
            content = $Message
        } | ConvertTo-Json
        $null = Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
        [pscustomobject]@{
            Message = $Message
            Status  = "Sent"
        }
    }
}