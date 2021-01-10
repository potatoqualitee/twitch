function Start-TvCommercial {
    <#
    .SYNOPSIS
        Starts a commercial

    .DESCRIPTION
        Starts a commercial

    .PARAMETER Duration
        How many seconds the commercial should last

    .EXAMPLE
        PS> Start-TvCommercial

        Starts a 60 second commercial

    .EXAMPLE
        PS> Start-TvCommercial -Duration 30

        Starts a 30 second commercial

#>
    [CmdletBinding()]
    param(
        [int]$Duration = 60
    )
    begin {
        if (-not $script:userid) {
            $null = Get-Id
        }

        $body = @{
            broadcaster_id = $script:userid
            length         = $Duration
        }
    }
    process {
        Invoke-TvRequest -Method POST -Path "/channels/commercial" -Body $body
    }
}