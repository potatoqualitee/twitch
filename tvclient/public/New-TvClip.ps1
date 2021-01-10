function New-TvClip {
    <#
    .SYNOPSIS
        Creates new clips

    .DESCRIPTION
        Creates new clips

    .PARAMETER UserName
        The username of the target account. Defaults to the account that generated the API key

    .EXAMPLE
        PS> New-TvClip

        Creates a new clip

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