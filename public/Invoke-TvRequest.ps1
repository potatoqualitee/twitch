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
        [ValidateSet("twitch", "streamlabs")]
        [string]$Type = "twitch",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path = "search/channels?query=powershell"
    )
    process {
        $PSDefaultParameterValues["*:UseBasicParsing"] = $true
        if ($Type -eq "twitch") {
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
        } else {
            if (-not $script:slsession -and -not $PSBoundParameters.ClientId -and -not $PSBoundParameters.Token) {
                throw "You must connect at least once using ClientId and Token"
            }

            $Path = $Path.TrimStart("/")

            if ($Path -eq "search/channels?query=powershell") {
                $Path = "token"
            }

            $params = @{
                Method = "POST"
                URI    = "https://streamlabs.com/api/v1.0/$Path"
            }
            write-warning "https://streamlabs.com/api/v1.0/$Path"
            <#
    //if using Guzzle 6+ change "body" to "form_params"
    $response = $client->post('https://streamlabs.com/api/v1.0/token', [
      'body' => [
        'grant_type'    => 'authorization_code',
        'client_id'     => 'YOUR_CLIENT_ID',
        'client_secret' => 'YOUR_CLIENT_SECRET',
        'redirect_uri'  => 'YOUR_CLIENT_REDIRECT_URI',
        'code'          => $_GET['code']
      ]
    ]);
    #sample code:
curl --request POST "https://streamlabs.com/api/v1.0/token" -d "grant_type=authorization_code&client_id=<client_id>&client_secret=<client_secret>&redirect_uri=<redirect_uri>&code=<code>"

Authorize: https://streamlabs.com/api/v1.0/authorize?response_type=code&client_id=gpQvF31AaIZiS62Bu8OlmDv1DKOaPJgZeFURGpCG&redirect_uri=https://sanakitty.github.io/&scope=points.read+points.write

    #>
            if ($script:slsession) {
                $params.WebSession = $script:slsession
            } else {
                $body = @{
                    grant_type    = "authorization_code"
                    client_id     = $ClientId
                    client_secret = $Token
                    redirect_uri  = "https://localhost/"
                    response_type = "code"
                    scope         = "points.read"
                }
                $params.Body = $body
                $params.SessionVariable = "websession"
            }

            try {
                Invoke-RestMethod @params -ErrorAction Stop -ContentType "application/x-www-form-urlencoded"
            } catch {
                throw $_
            }

            if (-not $script:slsession) {
                $script:slsession = $websession
            }
        }
    }
}