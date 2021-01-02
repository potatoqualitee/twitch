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
        [string]$ClientId = (Get-TvConfigValue -Name ClientId),
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Secret")]
        [string]$Token = (Get-TvConfigValue -Name Token),
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path = "search/channels?query=powershell",
        [ValidateSet("GET","POST")]
        [string]$Method = "GET",
        [psobject]$Body,
        [switch]$Raw
    )
    process {

        if (-not $script:session -and -not $ClientId -and -not $Token) {
            throw "You must set a ClientId and Token using Set-TvConfig"
        }

        $Path = $Path.TrimStart("/")

        $params = @{
            Method = $Method
            URI    = "https://api.twitch.tv/helix/$Path"
        }

        if ($PSBoundParameters.Body) {
            $params.Body = $Body | ConvertTo-Json
            $params.ContentType = "application/json"
        }

        if ($script:session) {
            $params.WebSession = $script:session
        } else {
            # create web session and get follows/subs
            $headers = @{
                "client-id"     = $ClientId
                "Authorization" = "Bearer $Token"
            }
            $params.Headers = $headers
            $params.SessionVariable = "websession"
        }

        try {
            $results = Invoke-RestMethod @params -ErrorAction Stop
            if ($results.data -and -not $Raw) {
                $results.data
            } else {
                $results
            }
        } catch {
            throw $_
        }

        if (-not $script:session) {
            $script:session = $websession
        }
    }
}