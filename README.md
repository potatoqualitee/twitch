This is the repo for two twitch modules. Below is a quick overview. More documentation can be found by clicking on the module directories.

To see all of the commands available, install and run:

```
Get-Command -Module tvbot, tvclient
```

Installation instructions can be found at [tvclient](https://github.com/potatoqualitee/twitch/blob/main/tvclient/) and [tvbot](https://github.com/potatoqualitee/twitch/blob/main/tvbot/).

## tvclient

<img align="left" src="https://github.com/potatoqualitee/twitch/blob/main/tvclient/icon.png?raw=true" alt="tvclient logo">  <br/></br>[tvclient](https://github.com/potatoqualitee/twitch/blob/main/tvclient/) is a PowerShell client for the [twitch.tv](https://twitch.tv) API.
<p>&nbsp;</p>

### Basic usage

Set your variables
```
$splat = @{
    ClientId = "abcdefh01234567ijklmop"
    Token    = "01234567fghijklmnopqrs"
}

Set-TvConfig @splat
```

And run your commands
```
Get-TvSubscriber
Get-TvFollower -Since LastStream
Get-TvUser -UserName potatoqualitee
```
Read more at [tvclient](https://github.com/potatoqualitee/twitch/blob/main/tvclient/).

## tvbot

<img align="left" src="https://github.com/potatoqualitee/twitch/blob/main/tvbot/icon.png?raw=true" alt="tvbot logo">  <br/></br>[tvbot](https://github.com/potatoqualitee/twitch/blob/main/tvbot/) is a pi-friendly PowerShell bot for [twitch.tv](https://twitch.tv) that works on the Windows, Linux, and mac OS.
<p>&nbsp;</p>

### Basic usage

Set your variables

```
$splat = @{
    BotClientId = "abcdefh01234567ijklmop"
    BotToken    = "01234567fghijklmnopqrs"
    BotChannel  = "potatoqualitee"
    BotOwner    = "potatoqualitee", "afriend"
}

Set-TvConfig @splat
```

And start your bot

```
Start-TvBot
```
Read more at [tvbot](https://github.com/potatoqualitee/twitch/blob/main/tvbot/).
