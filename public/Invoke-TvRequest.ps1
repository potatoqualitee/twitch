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
        [string]$Secret,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path
    )
    process {
        if (-not $script:session -and -not $PSBoundParameters.ClientId -and -not $PSBoundParameters.Secret) {
            throw "You must connect at least once using ClientId and Secret"
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
                "Authorization" = "Bearer $Secret"
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