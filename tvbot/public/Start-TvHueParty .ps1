function Start-TvHueParty {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string[]]$Group,
        [ValidateSet("Loop")]
        [string]$Type = "Loop",
        [int]$Duration = 10
    )
    process {
        <# Thanks https://blog.kloud.com.au/2018/03/19/commanding-your-philips-hue-lights-with-powershell/
        #>
        $huehub = Get-TvConfigValue -Name HueHub
        $apikey = Get-TvConfigValue -Name HueToken

        if (-not $huehub -or -not $huetoken) {
            throw "You must set your HueHub and HueToken configuration to continue. Visit https://sqlps.io/hue for more information, then`n Set-TvConfig -HueHub abc -HueToken xyz"
        }

        Write-TvSystemMessage -Type Verbose -Message "Sending commands to http://$huehub"
        # verbose disabled any further because it exposes the key
        $VerbosePreference = "SilentlyContinue"

        $baseurl = "http://$huehub/api/$apikey"

        switch ($Type) {
            "Loop" {
                $bodyon = @{
                    "on"     = "$true".ToLower()
                    "effect" = "colorloop"
                } | ConvertTo-Json

                $bodyoff = @{
                    "effect" = "none"
                } | ConvertTo-Json
            }
        }

        foreach ($groupname in $group) {
            $url = "$baseurl/groups/$group"
            $lights = (Invoke-RestMethod -Method Get -Uri $url).lights
            foreach ($light in $lights) {
                $null = Invoke-RestMethod -Method PUT -Uri "$baseurl/lights/$light/state" -Body $bodyon -ContentType "application/json"
            }
        }

        Start-Sleep -Seconds $Duration

        foreach ($groupname in $group) {
            $url = "$baseurl/groups/$group"
            $lights = (Invoke-RestMethod -Method Get -Uri $url).lights
            foreach ($light in $lights) {
                $null = Invoke-RestMethod -Method PUT -Uri "$baseurl/lights/$light/state" -Body $bodyoff -ContentType "application/json"
            }
            [pscustomobject]@{
                Group  = $groupname
                Status = "Complete"
            }
        }
    }
}