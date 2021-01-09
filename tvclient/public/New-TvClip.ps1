function New-TvClip {
    <#
    .SYNOPSIS
        Gets Twitch User
    #>
    [CmdletBinding()]
    param(
        [string]$UserName
    )
    process {
        if (-not $PSBoundParameters.UserName) {
            if (-not (Get-TvStream)) {
                Write-Warning "You must be streaming to create a clip"
                return
            }
        }
        $id = (Get-TvUser -UserName $UserName).id
        if ($id) {
            Invoke-TvRequest -Method POST -Path "/clips?broadcaster_id=$id"
        } else {
            throw "$UserName not found"
        }
    }
}