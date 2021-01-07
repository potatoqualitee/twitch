
## tvbot

<img align="left" src="https://github.com/potatoqualitee/twitch/blob/main/tvbot/icon.png?raw=true" alt="tvbot logo">  <br/></br>`tvbot` is a PowerShell bot for [https://twitch.tv](twitch.tv) that works on the Windows, Linux, mac OS and Raspberry Pi.
<p>&nbsp;</p>


## Install

Create a bot account on twitch, then get an oauth token from [twitchtokengenerator.com](https://twitchtokengenerator.com/) or [twitchapps.com/tmi](https://twitchapps.com/tmi/).


Next, change your execution policy, if needed, then install `tvbot` from the PowerShell Gallery.

```
# Set execution policy to allow local scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# OPTIONAL: Trust the Microsoft Gallery to avoid prompts
Set-PSRepository PSGallery -InstallationPolicy Trusted

# Install the tvbot PowerShell module
Install-Module tvbot
```

## Config

Once `tvbot` is installed, set your bot client id and token using the token generated earlier.

```
$splat = @{
    BotClientId = "abcdefh01234567ijklmop"
    BotToken    = "01234567fghijklmnopqrs"
    BotChannel  = "potatoqualitee"
    BotOwner    = "potatoqualitee", "afriend"
}

Set-TvConfig @splat
```

If you do not set a channel, the bot will join its own channel.

## Start

Next, start it up.

```
Start-TvBot
```

If you are on a Windows 10 machine and running PowerShell 5.1, the bot will open a new window, then minimize to the taskbar as a notify icon.

To run the bot in the current console, use the `NoHide` parameter.

```
Start-TvBot -NoHide
```

Note that this will run the bot infinitely so you will not be brought back to a prompt.

To run the bot as a background job, run the following:
```
Start-Job -ScriptBlock { Start-TvBot -NoHide }
```

## Interact
This starts a bot named mypsbot (which, in this case, would be a twitch account), then joins the `potatoqualitee` chat room.

* `!ping` - says "pong" back
* `!pwd` - shows the present working directory

The owner(s) of the bot can issue the following command:

* `!quit` - disconnects the bot and quits the script

To interact with the bot, join the same channel and execute a command.