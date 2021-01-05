function Get-Avatar {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$UserName
    )
    process {
        if ($script:cache[$UserName]) {
            $script:cache[$UserName]
        } else {
            $avatar = (Get-TvUser -UserName $UserName).ProfileImageUrl
            $script:cache[$UserName] = $avatar
            $avatar
        }
    }
}