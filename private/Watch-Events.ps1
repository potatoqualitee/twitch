function Watch-Events {
    <#
    .SYNOPSIS
        Watches for subs, follows, bits and raids

#>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Channel = "potatoqualitee"
    )
    process {
        Invoke-TvRequest -Path /users/follows?to_id=403789625
        $stream = Invoke-TvRequest -Path /streams?user_login=$Channel
        $viewcount = $stream.data.viewer_count
        if (-not $viewcount) {
            $viewcount = 0
        }
    }
}