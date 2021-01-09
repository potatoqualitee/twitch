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
        $id = (Get-TvUser -UserName $UserName).id
        if ($id) {
            Invoke-TvRequest -Method POST -Path "/clips?broadcaster_id=$id"
        } else {
            throw "$UserName not found"
        }
    }
}