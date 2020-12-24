function Invoke-TvRequest {
    <#
    .SYNOPSIS
        Connects to a Twitch

    .DESCRIPTION
        Connects to a Twitch

    .EXAMPLE
        PS C:\>

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ClientId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Secret")]
        [string]$Token,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path = "search/channels?query=powershell"
    )
    process {
        $PSDefaultParameterValues["*:UseBasicParsing"] = $true
        if (-not $script:session -and -not $PSBoundParameters.ClientId -and -not $PSBoundParameters.Token) {
            throw "You must connect at least once using ClientId and Token"
        }

        $Path = $Path.TrimStart("/")

        $params = @{
            Method = "GET"
            URI    = "https://api.twitch.tv/helix/$Path"
        }

        if ($script:session) {
            $params.WebSession = $script:session
        } else {
            $headers = @{
                "client-id"     = $ClientId
                "Authorization" = "Bearer $Token"
            }
            $params.Headers = $headers
            $params.SessionVariable = "websession"
        }

        try {
            Invoke-RestMethod @params -ErrorAction Stop
        } catch {
            throw $_
        }

        if (-not $script:session) {
            $script:session = $websession
        }
    }
}