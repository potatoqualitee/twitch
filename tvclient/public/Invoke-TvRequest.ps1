function Invoke-TvRequest {
    <#
    .SYNOPSIS
        Invokes a Twitch API request

    .DESCRIPTION
        Invokes a Twitch API request.

        This is basically an internal command that was added to the exported commands for convenience.

    .PARAMETER ClientId
        The target ClientId. Uses the ClientId config value by default.

    .PARAMETER Token
        The target Token. Uses the Token (Get-TvConfigValue -Name Token) config value by default.

    .PARAMETER Path
        The destination path. Basically, anything after https://api.twitch.tv/helix

    .PARAMETER Method
        The HTTP method, including Get, Post, Put and Delete

    .PARAMETER Body
        The body, in hashtable format

    .PARAMETER Raw
        By default, results are processed into PowerShell-styled output. Use Raw to see exactly what comes back from twitch.

    .EXAMPLE
        PS> Invoke-TvRequest -Path /users

        Executes a GET on https://api.twitch.tv/helix/users

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
        [string]$Path = "users",
        [ValidateSet("GET","POST")]
        [string]$Method = "GET",
        [psobject]$Body,
        [switch]$Raw
    )
    process {
        if (-not $script:session -and -not $ClientId -and -not $Token) {
            Write-Error -ErrorAction Stop -Message "You must set a ClientId and Token using Set-TvConfig. You can generate your tokens at https://twitchtokengenerator.com"
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
            if ($Raw) {
                return $results
            }
            if ($results.data.Count -eq 0 -and $results.pagination) {
                return
            }
            if ($results.data) {
                $results.data | ConvertFrom-RestResponse
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