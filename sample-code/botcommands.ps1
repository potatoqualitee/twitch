# post to a discord channel when someone posts a link
if ($message -match "http|ftp|https" -and $displayname -notin $userstoignore) {
    $regex = '(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?'
    $urls = ($message | Select-String -Pattern $regex -AllMatches).Matches
    foreach ($url in $urls.Value) {
        $msg = "$displayname posted: $url"
        Write-TvSystemMessage -Type Verbose -Message $msg
        Send-TvDiscordMessage -Message $msg
    }
}