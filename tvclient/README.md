
## tvclient

<img align="left" src="https://github.com/potatoqualitee/twitch/blob/main/tvclient/icon.png?raw=true" alt="tvclient logo">  <br/></br>`tvclient` PowerShell client for the [https://twitch.tv](Twitch) API.
<p>&nbsp;</p>


## Install

Get an API key from Twitch from [twitchtokengenerator.com](https://twitchtokengenerator.com/) or [twitchapps.com/tmi](https://twitchapps.com/tmi/).

Next, change your execution policy, if needed, then install `tvclient` from the PowerShell Gallery.

```
# Set execution policy to allow local scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# OPTIONAL: Trust the Microsoft Gallery to avoid prompts
Set-PSRepository PSGallery -InstallationPolicy Trusted

# Install the tvclient PowerShell module
Install-Module tvclient
```

## Config

Once `tvclient` is installed, set your client id and token using the token generated earlier.

```
$splat = @{
    ClientId = "abcdefh01234567ijklmop"
    Token    = "01234567fghijklmnopqrs"
}

Set-TvConfig @splat
```

## Configure

Next, check out your configuration.

```
Get-TvConfig
```

```
Edit-TvConfig
```


## Explore

Next, check out the commands that are available.

```
Get-Command -Module tvclient
```

## Run

Time to run some commands!

Want to see your subscribers?

```
Get-TvSubscriber
```

Or how about followers since your last stream?

```
Get-TvFollower -Since LastStream
```

Want to see who followed since your stream started?

```
Get-TvFollower -Since StreamStarted
```

Or who is a mod?

```
Get-TvModerator
```

You can even get details about other users by using the `UserName` parameter on several commands.

```
Get-TvUser -UserName potatoqualitee
Get-TvFollower -UserName potatoqualitee
```

Have more than 50 followers? Scroll through them using the `Next` switch.

```
Get-TvFollower -UserName potatoqualitee -Next
```
